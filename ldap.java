import javax.naming.Context;
import javax.naming.directory.DirContext;
import javax.naming.directory.InitialDirContext;
import java.util.Hashtable;

public class LdapExample {
    public static void main(String[] args) {
        // Ustawienia truststore
        System.setProperty("javax.net.ssl.trustStore", "path/to/truststore.jks");
        System.setProperty("javax.net.ssl.trustStorePassword", "truststorepassword");

        // Parametry połączenia LDAP
        String url = "ldaps://ldap.example.com:636";
        String baseDN = "dc=example,dc=com";
        String userDN = "cn=admin,dc=example,dc=com";
        String password = "password";

        // Ustawienia dla kontekstu LDAP
        Hashtable<String, String> env = new Hashtable<>();
        env.put(Context.INITIAL_CONTEXT_FACTORY, "com.sun.jndi.ldap.LdapCtxFactory");
        env.put(Context.PROVIDER_URL, url);
        env.put(Context.SECURITY_AUTHENTICATION, "simple");
        env.put(Context.SECURITY_PRINCIPAL, userDN);
        env.put(Context.SECURITY_CREDENTIALS, password);
        env.put(Context.SECURITY_PROTOCOL, "ssl");  // Użycie SSL/TLS

        try {
            // Utworzenie kontekstu
            DirContext ctx = new InitialDirContext(env);
            System.out.println("Połączenie LDAPS zostało nawiązane!");

            // Możesz teraz wykonać operacje LDAP na kontekście `ctx`
            // Na przykład wyszukiwanie, dodawanie, modyfikowanie lub usuwanie wpisów

            // Zamknięcie kontekstu po zakończeniu
            ctx.close();
        } catch (Exception e) {
            e.printStackTrace();
            System.err.println("Połączenie LDAPS nie powiodło się.");
        }
    }
}
