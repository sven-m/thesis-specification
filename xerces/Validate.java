import javax.xml.transform.Source;
import javax.xml.transform.stream.StreamSource;
import javax.xml.validation.Schema;
import javax.xml.validation.SchemaFactory;
import javax.xml.validation.Validator;

import java.io.File;
import java.io.IOException;
import org.xml.sax.SAXException;



public class Validate {
  public static final String SCHEMA_OPT_PREFIX_CHAR = "s";
  public static final String XML_OPT_PREFIX_CHAR = "x";


  public static void main(String[] args) {
    String schemaFile = null;
    String xmlFile = null;
    boolean skip = false;

    for (int i = 0; i < args.length; i++) {
      if (skip) {
        skip = false;
        continue;
      }

      if (args[i].startsWith("-")) {
        String option = args[i].substring(1);

        if (option.equals(SCHEMA_OPT_PREFIX_CHAR)) {
          if (args.length < i) {
            callError("Argument for option -" + SCHEMA_OPT_PREFIX_CHAR + " missing");
          }
          schemaFile = args[i + 1];
          skip = true;
        }
        else if (option.equals(XML_OPT_PREFIX_CHAR)) {
          if (args.length < i) {
            callError("Argument for option -" + XML_OPT_PREFIX_CHAR + " missing");
          }
          xmlFile = args[i + 1];

          skip = true;
        } else {
          callError("Invalid option: -" + option);
        }
      } else {
        callError("Invalid argument: " + args[i]);
      }
    }

    if ((schemaFile == null) || (xmlFile == null)) {
      callError("Schema or XML file not specified");
    }

    validate(xmlFile, schemaFile);

  }

  private static void callError(String errorMessage) {
    /* The program has been called incorrectly. Print the given error message
     * and quit */

    System.err.println(errorMessage);

    printUsageMessage();

    System.exit(1);
  }

  private static void printUsageMessage() {
    System.err.println("Usage:");
    System.err.println("  java Validate -s <schema file> -x <xml file>");
  }

  private static void validate(String xmlFileName, String schemaFileName) {
    StreamSource[] schemaDocuments = new StreamSource[] {
      new StreamSource(new File(schemaFileName))
    };
    Source instanceDocument = new StreamSource(new File(xmlFileName));

    SchemaFactory sf = SchemaFactory.newInstance(
        "http://www.w3.org/XML/XMLSchema/v1.1");
    try {
      Schema s = sf.newSchema(schemaDocuments);
      Validator v = s.newValidator();
      v.validate(instanceDocument);
    } catch (SAXException | IOException e) {
      System.out.println("SAXException: " + e.getMessage());
    }

  }

}
