import java.io.BufferedInputStream;
import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.io.InputStream;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;

public class Build {
    // Get the current directory's path:
    static File inDir = new File(""), outDir = new File("builds");
    static String APP_PATH = inDir.getAbsolutePath();
    static String SKETCH_NAME;
    static StringBuilder commentStr = new StringBuilder();

    public static void addComment(String p_comment) {
        commentStr.append("// ");
        commentStr.append(p_comment);
        commentStr.append('\n');
    }

    public static void main(String[] args) throws Exception {
        if (!outDir.exists()) {
            System.out.println("Please make a folder named \"builds\" first!");
            System.exit(-1);
        }

        SimpleDateFormat dateFormat = new SimpleDateFormat(
                "h':'m' 'a', 'EEEEEEEE', 'd' 'MMMM', 'yyyy");
        String date = dateFormat.format(new Date());

        { // Setting up some more constants:
            String inDirPath = inDir.getAbsolutePath();
            APP_PATH = inDirPath;
            int lastSepId = APP_PATH.lastIndexOf(File.separator);
            SKETCH_NAME = APP_PATH.substring(
                    1 + APP_PATH.lastIndexOf(File.separator, lastSepId - 1), lastSepId);
        }

        // Make sure it is a directory so we can iterate through all files!
        APP_PATH = APP_PATH.substring(0, APP_PATH.lastIndexOf(File.separator));
        inDir = new File(APP_PATH); // Remake that file object so it points to this directory.

        ArrayList<File> pdeFiles = new ArrayList<File>(); // All `.pde` files.
        ArrayList<File> buildFiles = new ArrayList<File>(); // All Build files.

        // Get all `.pde` files:
        { // Putting these curly braces here so we de-allocate at least SOME memory!
          // (And get another way to acces that `files[]` name, :P)
            File[] pdeDir = inDir.listFiles(); // All the files in the sketch directory.

            for (File f : pdeDir)
                if (f.getAbsolutePath().endsWith("pde"))
                    pdeFiles.add(f);

        }

        if (pdeFiles.size() == 0) {
            System.out.println("Ahah! The parent folder has no Processing `.pde` files!");
            System.exit(0);
        }

        File fileForBuild = new File("builds" + File.separatorChar + "Build-1.java"); // Holds our build.

        int largestBuildNum = 1, currentFileBuildNum = 1;

        File[] buildsDir = outDir.listFiles(); // All the files in the build directory.
        for (File f : buildsDir) { // Get all `Build.java` files:
            String fname = f.getName();
            if (fname.startsWith("Build-")) {
                buildFiles.add(f);

                currentFileBuildNum = Integer.parseInt(fname.substring(
                        fname.indexOf('-') + 1, fname.indexOf("java") - 1));

                if (currentFileBuildNum > largestBuildNum) {
                    fileForBuild = f;
                    largestBuildNum = currentFileBuildNum;
                }
            }
        }
        buildFiles.clear();
        System.gc(); // Just giving it a hint to clean up.

        int BUILD_NUM = 1 + largestBuildNum;

        if (!fileForBuild.exists()) {
            fileForBuild.createNewFile();
            BUILD_NUM = 1;
        }

        fileForBuild = new File("builds" + File.separator + "Build-" + BUILD_NUM + ".java");
        fileForBuild.createNewFile();

        // Outputs to `Build.java`:
        FileOutputStream buildOutputStream = new FileOutputStream(fileForBuild);

        // Begin writing.
        System.out.printf("\nBuilding `%s` for sketch: `%s`...\n",
                fileForBuild.getName(), SKETCH_NAME);

        System.out.println(date);
        System.out.println("Build Progress:\n");

        // These comments are written into the file last. See line `171`.

        // Opens streams to each `.pde` and copy its text to our `Build.java` file:
        for (File f : pdeFiles) {
            // Inform the user:
            System.out.printf("Wrote `%s`...\n", f.getName());

            FileInputStream istr = new FileInputStream(f);

            // Write a message, "// `FileName.pde`:" into it!:
            buildOutputStream.write(("// `" + f.getName() + "`, `" +
                    getNumberofLinesInFile(f) + "` lines:\n").getBytes());
            buildOutputStream.write(istr.readAllBytes());
            buildOutputStream.write("\n".getBytes());

            istr.close(); // NO memory leaks!

            // Kinda unnecessary, but let's get all the safety we can:
            buildOutputStream.flush();
        }

        buildOutputStream.close();

        // Now, we will get the import statements from the file.

        // For holding each `import` statement from the build file:
        StringBuilder linesForImports = new StringBuilder();

        // Find each `import` statement in the build file and
        // write it into the `StringBuilder`:
        try (BufferedReader reader = new BufferedReader(new FileReader(fileForBuild))) {
            int nln = getNumberofLinesInFile(fileForBuild), count = 0;
            for (String line; (line = reader.readLine()) != null; count++) {
                if (count == nln)
                    break;
                if (line.trim().startsWith("import")) {
                    linesForImports.append("//");
                    linesForImports.append(line);
                    linesForImports.append("\n");
                }
            }
        }

        FileInputStream fin = new FileInputStream(fileForBuild);
        byte[] buildData = fin.readAllBytes();
        fin.close();

        // There will be comments at the top of the main sketch file,
        // just before the `import`s.
        addComment("Build `" + BUILD_NUM + "`.");
        addComment("Build for sketch: `" + SKETCH_NAME + "`.");
        addComment("Built on: `" + date + "`.");

        // Write all `import`s to the start, deleting them from their original position:
        try (BufferedWriter writer = new BufferedWriter(new FileWriter(fileForBuild))) {
            writer.write(commentStr.toString());

            writer.write("\n// Imports:\n");
            writer.write(linesForImports.toString());
            writer.append('\n');

            writer.write(new String(buildData));
            writer.flush();
        } catch (Exception e) {
        }

        System.out.println("\nDone building! :D");

        // Open that build file! :D
        new ProcessBuilder("cmd", "/c", "start", fileForBuild.getAbsolutePath()).start();
    }

    // [https://stackoverflow.com/a/453067/13951505]
    // `countLinesNew()`:
    public static int getNumberofLinesInFile(File p_file) throws IOException {
        int count = 0; // This was before the line with the `while (readChars == 1024)`, originally!
        try (InputStream is = new BufferedInputStream(new FileInputStream(p_file))) {
            byte[] c = new byte[1024];
            int readChars = is.read(c);

            // Bail out if nothing to read:
            if (readChars == -1)
                return 0;

            // Make it easy for the optimizer to tune this loop:
            while (readChars == 1024) {
                for (int i = 0; i < 1024; i++)
                    if (c[i] == '\n')
                        ++count;
                readChars = is.read(c);
            }

            // Count all remaining characters:
            while (readChars != -1) {
                for (int i = 0; i < readChars; i++)
                    if (c[i] == '\n')
                        ++count;
                readChars = is.read(c);
            }

            // <Return statement went here originally!>
        }
        return count == 0 ? 1 : count;
    }

}
