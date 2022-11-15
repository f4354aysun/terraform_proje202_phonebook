resource "aws_launch_template" "ec2" {
  name            = "ec2"
  image_id        = "ami-09d3b3274b6c5d4aa"
  instance_type   = "t2.micro"
  key_name        = "aysunKEY"
  security_groups = [aws_security_group.ec2_sg.id]
  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "Web Server of Phonebook App"
    }
  }
  data "aws_availability_zones" "all_availability_zones" {
    all_availability_zones = true
  }
  user_data = filebase64("${path.module}/userdata.sh")
}



resource "aws_autoscaling_group" "alb_sg" {
  name                      = "phonebook_asg"
  max_size                  = 4
  min_size                  = 1
  health_check_grace_period = 300
  health_check_type         = "ELB"
  desired_capacity          = 2
  vpc_zone_identifier       = aws_subnet.default.id
  launch_template {
    id      = aws_launch_template.ec2.id
    version = "$Latest"
  }
}

resource "aws_lb" "load_balancer" {
  name               = "phonebook_lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [aws_subnet.default.id]

  }

resource "aws_lb_target_group" "alb_tg" {
  name        = "phonebook-alb-tg"
  target_type = "alb"
  port        = 80
  protocol    = "TCP"
  vpc_id      = aws_vpc.default.id
  health_check {
    healthy_threshold = 5
    unhealthy_threshold = 3
    port        = 80
    protocol    = "TCP"

  }
}
 resource "aws_lb_listener" "lb_list" {
  load_balancer_arn = aws_lb.load_balancer.id

  default_action {
    target_group_arn = aws_lb_target_group.alb_tg.id
    type             = "forward"
  }
}

resource "aws_db_instance" "mysql" {
  allocated_storage    = 10
  db_name              = "phonebook_db"
  engine               = "mysql"
  engine_version       = "8.0.19"
  instance_class       = "db.t2.micro"
  username             = "admin"
  password             = "Clarusway_123"
  port = "3306"
  security_group_names = "aws_security_group.rds_db_sg.id"
  publicly_accessible = true

}