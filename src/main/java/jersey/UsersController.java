package jersey;

import org.json.JSONObject;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import javax.inject.Inject;
import javax.inject.Named;
import javax.ws.rs.*;
import javax.ws.rs.core.*;
import java.net.URI;
import java.net.URISyntaxException;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;
import java.util.stream.StreamSupport;

import static javax.ws.rs.core.Response.Status.CONFLICT;

/**
 * Created by yairshefi on 9/14/16.
 */
@Named
@Path("/users")
public class UsersController {

    private static Logger logger = LoggerFactory.getLogger(UsersController.class);

    private final UserRepository userRepository;

    @Inject
    public UsersController(final UserRepository userRepository) {
        logger.debug("initializing " + UsersController.class.getName() + "...");
        this.userRepository = userRepository;
        logger.debug("initialized " + UsersController.class.getName() + " successfully");
    }

    private User overridePassword(final User user) {
        return new User(user.getId(), user.getName(), "******", user.getRoles(), user.getCreatedTime(), user.getModifiedTime());
    }

    @GET
    @Produces(MediaType.APPLICATION_JSON)
    public List<User> getUsers(@QueryParam("sortField") final String sortField,
                               @QueryParam("sortOrder") final SortOrder sortOrder) throws URISyntaxException {

        logger.debug("UserController.getUsers(): entered");

        final Comparator<User> comparator = resolveComparatorByField(sortField);

        final List<User> users = StreamSupport.stream(
                userRepository.findAll().spliterator(), false)
                    .map(this::overridePassword)
                    .sorted(comparator)
                    .collect(Collectors.toList());

        if (sortOrder == SortOrder.DESC) {
            Collections.reverse(users);
        } // else defaults to ASC

        return users;
    }

    private Comparator<User> resolveComparatorByField(@QueryParam("sortField") String sortField) {
        Comparator<User> comparator = Comparator.comparingLong(User::getCreatedTime);
        if (sortField != null) {
            switch (sortField) {
                case "id":
                    comparator = Comparator.comparing(User::getId);
                    break;
                case "name":
                    comparator = Comparator.comparing(User::getName);
                    break;
                case "roles": // assuming o2 isn't null
                    comparator = (o1, o2) -> o1.getRoles().toString().compareTo(o2.getRoles().toString());
                    break;
                case "createdTime":
                    comparator = Comparator.comparingLong(User::getCreatedTime);
                    break;
                case "modifiedTime":
                    comparator = Comparator.comparingLong(User::getModifiedTime);
                    break;
                default:
                    logger.warn("Ignoring unknown sortField query parameter: " + sortField);
                    break;
            }
        }
        return comparator;
    }

    @POST
    @Consumes(MediaType.APPLICATION_JSON)
    public Response createUser(final User user) throws URISyntaxException {
        logger.debug("UserController.createUser(): entered");
        final long now = System.currentTimeMillis(); // for setting createdTime and modifiedTime of new User
        final User newUser =
                new User(UUID.randomUUID().toString(), user.getName(), user.getPassword(), user.getRoles(), now, now);
        userRepository.save(newUser);
        return Response.created(new URI(newUser.getId())).build();
    }

    @DELETE
    @Path("{id}")
    @Produces(MediaType.APPLICATION_JSON)
    public Response deleteUser(@PathParam("id") String userId, @Context UriInfo uriInfo) throws URISyntaxException {

        final User foundUser = userRepository.findOne(userId);

        if (foundUser == null) { // nothing to delete - job is done!
            return Response.noContent().location(new URI("/users")).build(); // back to get users
        }

        if (foundUser.getRoles().stream().noneMatch(role -> role.equalsIgnoreCase("admin"))) {
            userRepository.delete(userId); // user isn't admin - allow deletion
            return Response.noContent().location(new URI("/users")).build(); // back to get users
        }

        // this user is admin - so delete only if it isn't the last admin on earth
        final boolean lastAdmin =
            userRepository.findBySingleRole("admin").stream()
                    .noneMatch(
                            adminUser -> ! adminUser.getId().equals(foundUser.getId()));

        if ( ! lastAdmin) { // allow deletion:
            userRepository.delete(userId);
            return Response.noContent().location(new URI("/users")).build(); // back to get users
        }

        // this is the last admin - forbid deletion:
        final String errorMessage = String.format(
                "Cannot delete user %s. Deleting a user with the last admin role is not allowed.", foundUser.getName());
        logger.warn(errorMessage);
        final String requestUri = uriInfo.getRequestUri().toString();
        final ErrorHttpResponse errorResponse = new ErrorHttpResponse(requestUri, errorMessage);
        final String errorResponseJson = new JSONObject(errorResponse).toString();
        return Response
                    .status(CONFLICT)
                    .header(HttpHeaders.CONTENT_LENGTH, errorResponseJson.length())
                    .entity(errorResponseJson)
                    .location(new URI("/users")).build(); // back to get users
    }

    @PUT
    @Path("{id}")
    @Consumes(MediaType.APPLICATION_JSON)
    public Response updateUser(@PathParam("id") String userId, final User user) throws URISyntaxException {
        final User foundUser = userRepository.findOne(userId);
        if (foundUser == null) {
            return Response.status(Response.Status.NOT_FOUND).location(new URI("/users")).build(); // back to get users
        }

        /* merge 'user' into 'foundUser' by building a new User instancem
           of which field-values are taken from received 'user' instance - if such field-valuse exist.
           Otherwise - the field-valuse is taken from 'foundUser'. */
        final User mergedUser = new User(
                userId,
                firstNonNull(user.getName(), foundUser.getName()),
                firstNonNull(user.getPassword(), foundUser.getPassword()),
                firstNonNull(user.getRoles(), foundUser.getRoles()),
                foundUser.getCreatedTime(), // created time should never change - taking value from 'foundUser'
                System.currentTimeMillis()); // modified time is NOW because it's modified now :)
        userRepository.save(mergedUser);
        return Response.noContent().location(new URI(mergedUser.getId())).build();

    }

    public static <T> T firstNonNull(final T t1, final T t2) {
        return t1 != null ? t1 : t2;
    }
}
