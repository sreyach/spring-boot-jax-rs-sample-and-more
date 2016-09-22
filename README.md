# test_web_app

Demonstrates a Spring Boot web-app with Jersey implementation of JAX-RS (as opposed to Spring MVC),
using Apache DBCP connected to in-memory H2 DB. It is based on
[Spring Boot's Jersey example project](https://github.com/spring-projects/spring-boot/tree/master/spring-boot-samples/spring-boot-sample-jersey).

To run it in IDE and embedded Tomcat:
  1. `git clone` the project.
  2. Import into IDE.
  3. Run main method in class `SampleJerseyApplication`.
  4. Open the browser in the address `localhost:8080`.

To run on standalone Tomcat:
  1. Run `mvn clean install`.
  2. Copy `<unzip_folder>/target/test-1.0.war` to `<tomcat_webapps_folder>/` (default is `<tomcat_install_folder>/libexec/webapps`).
  3. If not already started - start tomcat: run `<tomcat_install_folder>/bin/catalina start`.
  4. Open the browser in the address `localhost:8080/test-1.0` (here the context-path has to be used).

This should get you to the `index.jsp` file and you can test it from there. There's some further information there.

Tested on embedded + standalone Tomcat 8.5.5, H2 DB.
