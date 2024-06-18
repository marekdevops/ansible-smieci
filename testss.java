import javax.net.ssl.HttpsURLConnection;
import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.net.URL;

public class HttpsClient {
    public static void main(String[] args) {
        try {
            // Ustawienie TrustStore
            System.setProperty("javax.net.ssl.trustStore", "/ścieżka/do/truststore.jks");
            System.setProperty("javax.net.ssl.trustStorePassword", "hasło");

            // URL do połączenia HTTPS
            URL url = new URL("https://adres-do-polaczenia.com");
            HttpsURLConnection conn = (HttpsURLConnection) url.openConnection();

            // Sprawdzenie odpowiedzi
            BufferedReader br = new BufferedReader(new InputStreamReader(conn.getInputStream()));
            String input;
            while ((input = br.readLine()) != null) {
                System.out.println(input);
            }
            br.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
