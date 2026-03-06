package com.discretesoft.order.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;


@RestController
@RequestMapping("/api/orders")
public class OrderController {

    @Autowired
    private KafkaTemplate<String, String> kafkaTemplate;

    @PostMapping("/test")
    public ResponseEntity<String> sendTestOrder() {
        String message = "Test Order: order-" + System.currentTimeMillis();
        kafkaTemplate.send("order-topic", message);
        return ResponseEntity.ok("Message sent: " + message);
    }

    @GetMapping("/test2")
    public String getMethodName(@RequestParam String param) {
        return "Welcome to the new world";
    }
  
}