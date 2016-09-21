package jersey;

import org.springframework.data.repository.CrudRepository;

import java.util.List;

/**
 * Created by yairshefi on 9/14/16.
 */
public interface UserRepository extends CrudRepository<User, String> {

    List<User> findBySingleRole(final String role);
}
