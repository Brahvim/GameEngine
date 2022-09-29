static class Log {
  public final static byte lvInfo = 0, lvWarn = 1, lvError = 2; 
  public static boolean canInfo = true, canWarn = true, canError = true, canFile = true;

  public static boolean nerdCanInfo = true, nerdCanWarn = true, nerdCanError = true, 
    nerdCanLog = true, nerdCanFile = true;

  public static boolean canLogAtAll = true, canFileAtAll = true, 
    enabled = true, openFileOnExit = false;

  public static SimpleDateFormat dateFormat
    = new SimpleDateFormat("h':'m' 'a', 'EEEEEEEE', 'd' 'MMMM', 'yyyy");

  public static String filePath, absPath;
  public static File logFile;
  public static PrintWriter fileLogger;
}

// Initialize the logger:
public void initLog() {
  Log.filePath = sketchPath(/*"saves".concat(File.separator).concat*/(SKETCH_NAME).concat(".log"));
  Log.logFile = new File(Log.filePath);
  Log.absPath = Log.logFile.getAbsolutePath();

  // MAKE THE PROGRAM FASTER outside the PDE by disabling console-only logging!:
  Log.canLogAtAll = INSIDE_PDE;
  Log.nerdCanLog = INSIDE_PDE;

  if (!Log.logFile.exists())
  try {
    Log.logFile.createNewFile();
  }
  catch (IOException e) {
    // You can't call `logEx()` here!
    e.printStackTrace();
    Log.canFile = false;
  }

  Log.logFile.setWritable(true);
  try {
    Log.fileLogger = new PrintWriter(Log.logFile);
  }
  catch (Exception e) {
    // ...here neither!
    e.printStackTrace();
    Log.canFile = false;
  }
}

// Single String methods:

public static void logInfo(String p_message) {
  if (!Log.enabled)
    return;

  if (!Log.canInfo)
    return;

  if (Log.canLogAtAll)
    System.out.println(p_message);

  if (Log.canFileAtAll) {
    Log.fileLogger.printf("[Info] [%s] %s\n", Log.dateFormat.format(new Date()), p_message);
    Log.fileLogger.flush();
  }
}

public static void nerdLogInfo(String p_message) {
  if (!Log.enabled)
    return;

  if (!Log.nerdCanInfo)
    return;

  if (Log.nerdCanLog) {
    System.out.print("[Nerd-Info] ");
    System.out.println(p_message);
  }

  if (Log.nerdCanFile) {
    Log.fileLogger.printf("[Nerd-Info] [%s] %s\n", Log.dateFormat.format(new Date()), p_message);
    Log.fileLogger.flush();
  }
}

public static void logWarn(String p_message) {
  if (!Log.enabled)
    return;

  if (!Log.canWarn)
    return;

  if (Log.canLogAtAll)
    System.out.println("[!] " + p_message);

  if (Log.canFileAtAll) {
    Log.fileLogger.printf("[Warn] [%s] %s\n", Log.dateFormat.format(new Date()), p_message);
    Log.fileLogger.flush();
  }
}

public static void nerdLogWarn(String p_message) {
  if (!Log.enabled)
    return;

  if (!Log.nerdCanWarn)
    return;

  if (Log.nerdCanLog)
    System.out.println("[Nerd-Warn] " + p_message);

  if (Log.nerdCanFile) {
    Log.fileLogger.printf("[Nerd-Warn] [%s] %s\n", Log.dateFormat.format(new Date()), p_message);
    Log.fileLogger.flush();
  }
}


public static void logError(String p_message) {
  if (!Log.enabled)
    return;

  if (!Log.canError)
    return;

  if (Log.canLogAtAll)
    System.err.println(p_message);

  if (Log.canFileAtAll) {
    Log.fileLogger.printf("[ERROR] [%s] %s\n", Log.dateFormat.format(new Date()), p_message);
    Log.fileLogger.flush();
  }
}

public static void nerdLogError(String p_message) {
  if (!Log.enabled)
    return;

  if (!Log.nerdCanError)
    return;

  if (Log.nerdCanLog) {
    System.err.print("[Nerd] ");
    System.err.println(p_message);
  }

  if (Log.nerdCanFile) {
    Log.fileLogger.printf("[Nerd-Error] [%s] %s\n", Log.dateFormat.format(new Date()), p_message);
    Log.fileLogger.flush();
  }
}

// These two take in a `java.lang.RuntimeException`:

public static void logEx(Exception p_except) {
  if (!(Log.enabled || Log.nerdCanError))
    return;

  if (Log.nerdCanLog)
    p_except.printStackTrace(); // To the console it goes!

  // I learnt this on Stackoverflow, too. Didn't mention the source ; - ;)
  if (Log.canFileAtAll) {
    StringWriter sw = new StringWriter();
    PrintWriter pw = new PrintWriter(sw);
    p_except.printStackTrace(pw);

    try {
      sw.close();
    } 
    catch (IOException e) {
      // But Sir, this is 'a' `logEx()`.
      e.printStackTrace();
    }

    pw.close();

    Log.fileLogger.printf("[EXCEPTION] [%s]\n\t\t%s\n", 
      // The extra `\n` at the start is actually comfortable. Do not change that. Please trust me.
      Log.dateFormat.format(new Date()), sw.toString());

    Log.fileLogger.flush();
  }
}


public static void nerdLogEx(Exception p_except) {
  if (!(Log.enabled || Log.nerdCanError))
    return;

  if (Log.nerdCanLog)
    p_except.printStackTrace(); // To the console it goes!

  // I learnt this on Stackoverflow, too. Didn't mention the source ; - ;)
  if (Log.canFileAtAll) {
    StringWriter sw = new StringWriter();
    PrintWriter pw = new PrintWriter(sw);
    p_except.printStackTrace(pw);

    try {
      sw.close();
    } 
    catch (IOException e) {
      // But Sir, this is 'a' `logEx()`. :rofl:
      e.printStackTrace();
    }

    pw.close();

    if (Log.nerdCanFile) {
      Log.fileLogger.printf("[Nerd-Exception] [%s]\n\t\t%s\n", 
        // The extra `\n` at the start is actually comfortable. Do not change that. Please trust me.
        Log.dateFormat.format(new Date()), sw.toString());
      Log.fileLogger.flush();
    }
  }
}

// `Throwable`s, `Exception`s - nothing works!
public static void logThrownEx(RuntimeException p_thrown) {
  logEx(p_thrown);
  throw p_thrown;
}

// Varargs methods:

public static void nerdLogInfo(Object... p_args) {
  if (!(Log.enabled || Log.nerdCanInfo))
    return;

  if (Log.nerdCanLog) {
    for (int i = 0; i < p_args.length; i++)
      System.out.printf("%s", p_args[i]);
    System.out.write('\n');
  }

  if (Log.nerdCanFile) {
    Log.fileLogger.printf("[Nerd-Info] [%s] ", Log.dateFormat.format(new Date()));

    for (int i = 0; i < p_args.length; i++)
      if (p_args[i] != null)
        Log.fileLogger.printf("%s", p_args[i] instanceof String? p_args[i] : p_args[i].toString());
      else
        Log.fileLogger.printf("%s", "null");

    Log.fileLogger.write('\n');
    Log.fileLogger.flush();
  }
}


public static void logInfo(Object... p_args) {
  if (!(Log.enabled || Log.canInfo)) 
    return;

  if (Log.canLogAtAll) {
    for (int i = 0; i < p_args.length; i++)
      System.out.printf("%s", p_args[i]);
    System.out.write('\n');
  }

  if (Log.canFile) {
    Log.fileLogger.printf("[Nerd-Info] [%s] ", Log.dateFormat.format(new Date()));

    for (int i = 0; i < p_args.length; i++)
      if (p_args[i] != null)
        Log.fileLogger.printf("%s", p_args[i] instanceof String? p_args[i] : p_args[i].toString());
      else
        Log.fileLogger.printf("%s", "null");

    Log.fileLogger.write('\n');
    Log.fileLogger.flush();
  }
}


public static void nerdLogWarn(Object... p_args) {
  if (!(Log.enabled || Log.nerdCanWarn))
    return;

  if (Log.nerdCanLog) {
    for (int i = 0; i < p_args.length; i++)
      System.out.printf("%s", p_args[i]);
    System.out.write('\n');
  }

  if (Log.nerdCanFile) {
    Log.fileLogger.printf("[Nerd-Warn] [%s] ", Log.dateFormat.format(new Date()));

    for (int i = 0; i < p_args.length; i++)
      if (p_args[i] != null)
        Log.fileLogger.printf("%s", p_args[i] instanceof String? p_args[i] : p_args[i].toString());
      else
        Log.fileLogger.printf("%s", "null");

    Log.fileLogger.write('\n');
    Log.fileLogger.flush();
  }
}

public static void logWarn(Object... p_args) {
  if (!Log.enabled) 
    return;

  if (Log.canLogAtAll && Log.canWarn) {
    for (int i = 0; i < p_args.length; i++)
      System.out.printf("%s", p_args[i]);
    System.out.write('\n');
  }

  if (Log.canFileAtAll) {
    Log.fileLogger.printf("[Warn] [%s] ", Log.dateFormat.format(new Date()));

    for (int i = 0; i < p_args.length; i++)
      if (p_args[i] != null)
        Log.fileLogger.printf("%s", p_args[i] instanceof String? p_args[i] : p_args[i].toString());
      else
        Log.fileLogger.printf("%s", "null");

    Log.fileLogger.write('\n');
    Log.fileLogger.flush();
  }
}

public static void nerdLogError(Object... p_args) {
  if (!Log.enabled) 
    return;

  if (Log.nerdCanLog && Log.canError) {
    for (int i = 0; i < p_args.length; i++)
      System.out.printf("%s", p_args[i]);
    System.out.write('\n');
  }

  if (Log.nerdCanFile) {
    Log.fileLogger.printf("[Nerd-ERROR] [%s] ", Log.dateFormat.format(new Date()));

    for (int i = 0; i < p_args.length; i++)
      if (p_args[i] != null)
        Log.fileLogger.printf("%s", p_args[i] instanceof String? p_args[i] : p_args[i].toString());
      else
        Log.fileLogger.printf("%s", "null");

    Log.fileLogger.write('\n');
    Log.fileLogger.flush();
  }
}

public static void logError(Object... p_args) {
  if (!Log.enabled)
    return;

  if (Log.canLogAtAll && Log.canError) {
    for (int i = 0; i < p_args.length; i++)
      System.out.printf("%s", p_args[i]);
    System.out.write('\n');
  }

  if (Log.canFileAtAll) {
    Log.fileLogger.printf("[ERROR] [%s] ", Log.dateFormat.format(new Date()));

    for (int i = 0; i < p_args.length; i++)
      if (p_args[i] != null)
        Log.fileLogger.printf("%s", p_args[i] instanceof String? p_args[i] : p_args[i].toString());
      else
        Log.fileLogger.printf("%s", "null");

    Log.fileLogger.write('\n');
    Log.fileLogger.flush();
  }
}

void nerdLogToFile(int p_lv, Object... p_args) {
  if (!(Log.nerdCanFile && Log.enabled))
    return;

  if (Log.nerdCanFile) {
    Log.fileLogger.printf(
      p_lv == Log.lvError? "[Nerd-ERROR]" : p_lv == Log.lvWarn? "[Nerd-Warn]" : "[Nerd-Info]" 
      + " [%s] ", Log.dateFormat.format(new Date()));

    for (int i = 0; i < p_args.length; i++)
      if (p_args[i] != null)
        Log.fileLogger.printf("%s", p_args[i] instanceof String? p_args[i] : p_args[i].toString());
      else
        Log.fileLogger.printf("%s", "null");

    Log.fileLogger.printf("\n");
    Log.fileLogger.flush();
  }
}

void logToFile(int p_lv, Object... p_args) {
  if (!(Log.canFileAtAll && Log.enabled))
    return;

  if (Log.canFileAtAll) {
    Log.fileLogger.printf(
      p_lv == Log.lvError? "[ERROR]" : p_lv == Log.lvWarn? "[Warn]" : "[Info]" 
      + " [%s] ", Log.dateFormat.format(new Date()));

    for (int i = 0; i < p_args.length; i++)
      if (p_args[i] != null)
        Log.fileLogger.printf("%s", p_args[i] instanceof String? p_args[i] : p_args[i].toString());
      else
        Log.fileLogger.printf("%s", "null");

    Log.fileLogger.printf("\n");
    Log.fileLogger.flush();
  }
}
