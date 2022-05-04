import java.util.concurrent.locks.ReentrantLock;

public class Counter {
    private ReentrantLock lock = new ReentrantLock();
    private int count = 0;

    public static void main(String[] args) throws InterruptedException {
        Counter counter = new Counter();
        for (int i = 0; i < 10000; i++) {
            Thread t1 = new Thread(() -> {
                for (int j = 0; j < 500; j++) {
                    counter.count();
                }
            });
            t1.start();
        }
        Thread.sleep(5000);
        System.out.println(counter.getCount());
    }

    public void count() {
        lock.lock();
        try {
            count++;
        } finally {
            lock.unlock();
        }
    }

    public int getCount() {
        lock.lock();
        try {
            return count;
        } finally {
            lock.unlock();
        }
    }
}
