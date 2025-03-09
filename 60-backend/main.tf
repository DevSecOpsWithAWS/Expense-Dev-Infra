resource "aws_instance" "backend" {
  ami           = data.aws_ami.joindevops.id
  vpc_security_group_ids = [data.aws_ssm_parameter.backend_sg_id.value]
  instance_type = "t3.micro"
  subnet_id     = local.private_subnet_ids
  tags = {
    Name = "${var.project_name}-${var.environment}-backend"
  }
}

resource "null_resource" "backend" {
  # Changes to any instance of the cluster requires re-provisioning
  triggers = {
    #cluster_instance_ids = join(",", aws_instance.cluster[*].id)
    #instance_ids = join(",", aws_instance.backend[*].id)
    instance_id = aws_instance.backend.id
  }

  # Bootstrap script can run on any instance of the cluster
  # So we just choose the first in this case
  connection {
    host = aws_instance.backend.private_ip
    type = "ssh"
    user = "ec2-user"
    password = "DevOps321"
  }
  provisioner "file" {
    # Copy bootstrap script to the instance
    source      = "backend.sh"
    destination = "/tmp/backend.sh"
  }
  provisioner "remote-exec" {
    # Bootstrap script called with private_ip of each node in the cluster
    inline = [
      "chmod +x /tmp/backend.sh",
      "sudo sh /tmp/backend.sh ${var.environment}",
    ]
  }
}

#stopping the backend instance
resource "aws_ec2_instance_state" "backend" {
instance_id = aws_instance.backend.id
state = "stopped"
depends_on = [null_resource.backend]
}

#creating ami from the backend instance
resource "aws_ami_from_instance" "backend"{
name = local.resource_name
source_instance_id = aws_instance.backend.id
depends_on = [aws_ec2_instance_state.backend]
}

#deleting the backend instance
resource "null_resource" "backend_delete" {
  triggers = {
    instance_id = aws_instance.backend.id
  }
  provisioner "local-exec" {
    command = "aws ec2 terminate-instances --instance-ids ${aws_instance.backend.id}"
  }
  depends_on= [aws_ami_from_instance.backend]
}

#creating target group for backend
resource "aws_lb_target_group" "backend" {
  name     = local.resource_name
  port     = 8080
  protocol = "HTTP"
  vpc_id   = local.vpc_id
  deregistration_delay = 60
  health_check {
    path                = "/health"
    port                = 8080
    protocol            = "HTTP"
    interval            = 10
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher = "200-299"
  }
}

#creating launch template for backend
resource "aws_launch_template" "backend" {
  name = local.resource_name
  image_id = aws_ami_from_instance.backend.id

  instance_initiated_shutdown_behavior = "terminate"
  instance_type = "t3.micro"
  update_default_version = true
  vpc_security_group_ids = [local.backend_sg_id]

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = local.resource_name
    }
  }
}

#creating autoscaling group for backend

resource "aws_autoscaling_group" "backend" {
  name                      = local.resource_name
  max_size                  = 10
  min_size                  = 1
  health_check_grace_period = 180
  health_check_type         = "ELB"
  desired_capacity          = 1
  target_group_arns = [aws_lb_target_group.backend.arn]
  #force_delete              = true
  #placement_group           = aws_placement_group.test.id
  #launch_configuration      = aws_launch_configuration.foobar.name
  launch_template {
    id      = aws_launch_template.backend.id
    version = "$Latest"
  }
  vpc_zone_identifier       = local.private_subnet_idss

  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
    } 
    triggers = ["launch_template"] # Required for instance refresh
  }
  timeouts {
    delete = "10m"
  }
  tag {
    key                 = "Name"
    value               = local.resource_name
    propagate_at_launch = true
  }
   tag {
    key                 = "Environment"
    value               = "dev"
    propagate_at_launch = false
  }
}

resource "aws_autoscaling_policy" "backend" {
  name                   = "${local.resource_name}-backend"
  policy_type            = "TargetTrackingScaling"
  autoscaling_group_name = aws_autoscaling_group.backend.name
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = 70.0
  }
}


#creating listener rule for backend
resource "aws_lb_listener_rule" "backend" {
  listener_arn = data.aws_ssm_parameter.app_alb_listner_arn.value
  priority     = 10
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend.arn
  }

  condition {
    host_header {
      values = ["backend.app-${var.environment}.${var.domain_name}"]
    }
  }
}

