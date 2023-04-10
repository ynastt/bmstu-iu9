import java.io.BufferedReader;
import java.io.IOException;
import java.util.*;

public class Compiler {

    private SortedMap<Position, Message> messages;
    private HashMap<String, Integer> nameCodes;
    private List<String> names;

    public Compiler() {
        messages = new TreeMap<>();
        nameCodes = new HashMap<>();
        names = new ArrayList<>();
    }

    public int addName(String name) {
        if (nameCodes.containsKey(name)) {
            return nameCodes.get(name);
        } else {
            int code = names.size();
            names.add(name);
            nameCodes.put(name, code);
            return code;
        }
    }
    public String getName(int code) {
        return names.get(code);
    }
    public void addMessage(boolean isErr, Position c, String text) {
        messages.put(c, new Message(isErr, text));
    }

    public void outputMessages() {
        System.out.println("\nMessages:");
        for (Map.Entry<Position, Message> pair : messages.entrySet()) {
            System.out.print(pair.getValue().isError ? "Error" : "Warning");
            System.out.print(" " + pair.getKey() + ": ");
            System.out.println(pair.getValue().text);
        }
    }
}