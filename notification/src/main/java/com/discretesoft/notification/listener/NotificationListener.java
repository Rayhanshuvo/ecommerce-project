package com.discretesoft.notification.listener;

import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.stereotype.Component;

@Component
public class NotificationListener {

    @KafkaListener(topics = "order-topic", groupId = "notification-group")
    public void listen(String message) {
        System.err.println(" Notification received: " + message);
    }
}