package jersey;

import javax.persistence.*;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

import static javax.persistence.FetchType.EAGER;

/**
 * Created by yairshefi on 9/14/16.
 */
@Entity
@NamedQueries(@NamedQuery(name = "User.findBySingleRole", query = "from User u join u.roles r where r=?1"))
public class User {

    @Id
    private String id;

    private String name;

    private String password;

    @ElementCollection(fetch = EAGER)
    private List<String> roles;

    private Long createdTime;

    private Long modifiedTime;

    /**
     * For JPA usage only.
     */
    protected User() {}

    /**
     * Constructs a user in this app.<p></p>
     * {@link #createdTime} and {@link #modifiedTime} are set to {@link System#currentTimeMillis()}.
     *
     * @param id              should be a self-generated String representation of a {@link java.util.UUID}.
     *                        Typically, created by invoking {@link UUID#randomUUID()} followed by {@link UUID#toString()}.
     * @param name            the String the user uses when logging in.
     * @param password        this password the user uses when logging in.
     * @param roles           list of the roles this user possesses. Currently, a role could any String.
     *                        <b><i>However</i></b> - An "admin" role would prevent deleting this User,
     *                        in case this is the last User on the face of earth.
     * @param createdTime     creation time of this User in milliseconds since January 1<sup>st</sup>, 1970.
     * @param modifiedTime    last modification time of this User in milliseconds since January 1<sup>st</sup>, 1970.
     */
    public User(
            final String id,
            final String name,
            final String password,
            final List<String> roles,
            final Long createdTime,
            final Long modifiedTime ) {
        this.id = id;
        this.name = name;
        this.password = password;
        this.roles = new ArrayList(roles);
        this.createdTime = createdTime;
        this.modifiedTime = modifiedTime;
    }

    public String getId() {
        return id;
    }

    public String getName() {
        return name;
    }

    public String getPassword() {
        return password;
    }

    public List<String> getRoles() {
        return roles;
    }

    public Long getCreatedTime() {
        return createdTime;
    }

    public Long getModifiedTime() {
        return modifiedTime;
    }

    @Override
    public String toString() {
        return "User{" +
                "id='" + id + '\'' +
                ", name='" + name + '\'' +
                ", password='" + password + '\'' +
                ", roles=" + roles +
                ", createdTime=" + createdTime +
                ", modifiedTime=" + modifiedTime +
                '}';
    }
}
