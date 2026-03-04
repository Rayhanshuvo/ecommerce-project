CREATE USER IF NOT EXISTS 'app'@'%' IDENTIFIED BY 'app123';
GRANT ALL PRIVILEGES ON order_db.* TO 'app'@'%';
GRANT ALL PRIVILEGES ON notification.* TO 'app'@'%';