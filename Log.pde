static class Log {
  public static byte lvInfo = 0, lvWarn = 1, lvError = 2;
  public static byte logLevel = Log.lvError;
  public static boolean logToFile = true, openFileOnExit = true, 
    logToConsole = true, enabled = true;

  public static SimpleDateFormat dateFormat
    = new SimpleDateFormat("h':'m' 'a', 'EEEEEEEE', 'd' 'MMMM', 'yyyy");

  public static String filePath;
  public static File logFile;
  public static PrintWriter fileLogger;
}

// Initialize the logger:

public void initLog() {
  Log.filePath = 
    INSIDE_PDE? 
    sketchArgs[2].substring(14, sketchArgs[2].length()) + "\\" + SKETCH_NAME + ".log" 
    : SKETCH_NAME + ".log";
  Log.logFile = new File(Log.filePath);

  // MAKE THE PROGRAM FASTER outside the PDE by disabling console-only logging!:
  Log.logToConsole = !INSIDE_PDE;

  if (!Log.logFile.exists())
  try {
    Log.logFile.createNewFile();
  }
  catch(IOException ioe) {
  }

  Log.logFile.setWritable(true);
  println("Absolute log path:", Log.logFile.getAbsolutePath());
  try {
    Log.fileLogger = new PrintWriter(Log.logFile);
  }
  catch(Exception e) {
    e.printStackTrace();
  }
}

// Single String methods:

public static void logInfo(String p_message) {
  if (Log.logToConsole && Log.logLevel < Log.lvInfo)
    return;
  System.out.println(p_message);

  if (Log.logToFile) {
    Log.fileLogger.printf("[Info] [%s] %s\n", Log.dateFormat.format(new Date()), p_message);
    Log.fileLogger.flush();
  }
}


public static void logWarn(String p_message) {
  if (Log.enabled) {    
    if (Log.logToConsole && Log.logLevel < Log.lvWarn)
      return;
    System.out.println("[!] " + p_message);

    if (Log.logToFile) {
      Log.fileLogger.printf("[WARN] [%s] %s\n", Log.dateFormat.format(new Date()), p_message);
      Log.fileLogger.flush();
    }
  }
}

public static void logError(String p_message) {
  if (Log.enabled) {
    if (Log.logToConsole && Log.logLevel < Log.lvError)
      return;
    System.err.println(p_message);
    if (Log.logToFile) {
      Log.fileLogger.printf("[ERROR] [%s] %s\n", Log.dateFormat.format(new Date()), p_message);
      Log.fileLogger.flush();
    }
  }
}

// These two take in a `java.lang.RuntimeException`:

public static void logEx(Exception p_except) {
  if (Log.enabled) {
    if (Log.logToConsole && Log.logLevel == Log.lvError)
      p_except.printStackTrace(); // To the console it goes!

    // I learnt this on Stackoverflow, too. Didn't mention the source ; - ;)
    if (Log.logToFile) {
      StringWriter sw = new StringWriter();
      PrintWriter pw = new PrintWriter(sw);
      p_except.printStackTrace(pw);

      try {
        sw.close();
      } 
      catch(IOException e) {
      }

      pw.close();

      Log.fileLogger.printf("[EXCEPTION] [%s]\n\t\t%s\n", 
        Log.dateFormat.format(new Date()), sw.toString());

      Log.fileLogger.flush();
    }
  }
}

public static void logThrownEx(RuntimeException p_thrown) {
  logEx(p_thrown);
  throw p_thrown;
}

// Varargs methods:

public static void logInfo(Object... p_args) {
  if (!Log.enabled) 
    return;

  if (Log.logToConsole && Log.logLevel < Log.lvInfo) {
    for (int i = 0; i < p_args.length; i++)
      System.out.printf("%s", p_args[i]);
    System.out.write('\n');
  }

  if (Log.logToFile) {
    Log.fileLogger.printf("[Info] [%s] ", Log.dateFormat.format(new Date()));

    for (int i = 0; i < p_args.length; i++)
      Log.fileLogger.printf("%s", p_args[i] instanceof String? p_args[i] : p_args[i].toString());

    Log.fileLogger.write('\n');
    Log.fileLogger.flush();
  }
}

public static void logWarn(Object... p_args) {
  if (!Log.enabled) 
    return;

  if (Log.logToConsole && Log.logLevel < Log.lvInfo) {
    for (int i = 0; i < p_args.length; i++)
      System.out.printf("%s", p_args[i]);
    System.out.write('\n');
  }

  if (Log.logToFile) {
    Log.fileLogger.printf("[Warn] [%s] ", Log.dateFormat.format(new Date()));

    for (int i = 0; i < p_args.length; i++)
      Log.fileLogger.printf("%s", p_args[i] instanceof String? p_args[i] : p_args[i].toString());

    Log.fileLogger.write('\n');
    Log.fileLogger.flush();
  }
}

public static void logError(Object... p_args) {
  if (!Log.enabled) 
    return;

  if (Log.logToConsole && Log.logLevel < Log.lvInfo) {
    for (int i = 0; i < p_args.length; i++)
      System.out.printf("%s", p_args[i]);
    System.out.write('\n');
  }

  if (Log.logToFile) {
    Log.fileLogger.printf("[ERROR] [%s] ", Log.dateFormat.format(new Date()));

    for (int i = 0; i < p_args.length; i++)
      Log.fileLogger.printf("%s", p_args[i] instanceof String? p_args[i] : p_args[i].toString());

    Log.fileLogger.write('\n');
    Log.fileLogger.flush();
  }
}

void logToFile(int p_lv, Object... p_args) {
  if (!(Log.logToFile && Log.enabled))
    return;

  if (Log.logToFile) {
    Log.fileLogger.printf(
      p_lv == Log.lvError? "[ERROR]" : p_lv == Log.lvWarn? "[WARN]" : "[Info]" 
      + " [%s] ", Log.dateFormat.format(new Date()));

    for (int i = 0; i < p_args.length; i++)
      Log.fileLogger.printf("%s", p_args[i] instanceof String? p_args[i] : p_args[i].toString());

    Log.fileLogger.printf("\n");
    Log.fileLogger.flush();
  }
}
