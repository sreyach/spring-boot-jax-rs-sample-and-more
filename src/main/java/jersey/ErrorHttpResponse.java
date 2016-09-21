package jersey;

/**
 * Created by yairshefi on 9/21/16.
 */
public class ErrorHttpResponse {

    private final String requestUri;
    private final String message;

    public ErrorHttpResponse(String requestUri, String message) {
        this.requestUri = requestUri;
        this.message = message;
    }

    public String getRequestUri() {
        return requestUri;
    }

    public String getMessage() {
        return message;
    }
}
