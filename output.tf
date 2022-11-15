output "phonebook_web_url" {

    value = "http://${aws_lb.load_balancer.dns_name}"
  
}