
package whale.test;

import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.builder.SpringApplicationBuilder;
import org.springframework.context.ApplicationContext;
import org.springframework.context.ConfigurableApplicationContext;

@SpringBootApplication
public class Test {

    private static ApplicationContext context = null;

    public static ApplicationContext getContext() {
        return context;
    }

    public static <T extends Object> T getBean(Class<T> requiredType) {
        return context.getBean(requiredType);
    }

    public static void main(String[] args) {
        context = createApplicationContext(args);
        
        //TaskFrame mainMenuController = new TaskFrame();
        //mainMenuController.setVisible(true);
    }

    private static ConfigurableApplicationContext createApplicationContext(String[] args) {
        return new SpringApplicationBuilder(Test.class)
                .headless(false)
                .run(args);
    }
}