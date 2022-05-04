public class PingPong {
    public static void main(String[] args) {

        String command1 = "ping";
        String command2 = "pong";

        Thread t1 = new Thread(() -> {
            synchronized (command1) {
                for (int i = 0; i < 30; i++) {
                    System.out.println(command1);
                    try {
                        command1.notify();
                        command1.wait();
                    } catch (InterruptedException e) {
                        e.printStackTrace();
                    }
                    if (i == 29) {
                        command1.notify();
                    }
                }
            }
        });

        Thread t2 = new Thread(() -> {
            synchronized (command1) {
                for (int i = 0; i < 30; i++) {
                    System.out.println(command2);
                    try {
                        command1.notify();
                        command1.wait();
                    } catch (InterruptedException e) {
                        e.printStackTrace();
                    }
                    if (i == 29) {
                        command1.notify();
                    }
                }
            }
        });

        t1.start();
        t2.start();
    }
}
