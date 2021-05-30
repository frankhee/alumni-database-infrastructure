
resource "aws_default_vpc" "default_vpc" {}

resource "aws_default_subnet" "default_subnet_b" {
  availability_zone = "us-east-2b"
}

resource "aws_default_subnet" "default_subnet_c" {
  availability_zone = "us-east-2c"
}


resource "aws_ecr_repository" "alumni_database_ecr" {
  for_each             = var.repository_names
  name                 = each.value
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_iam_role" "ecsTaskExecutionRole" {
  name               = "ecsTaskExecutionRole"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "ecsTaskExecutionRole_policy" {
  role       = aws_iam_role.ecsTaskExecutionRole.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_ecs_cluster" "alumni_database_ecs_cluster" {
  name = "alumni_database_cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

resource "aws_ecs_service" "alumni_database_backend" {
  name            = aws_ecs_task_definition.alumni_database_backend_task.family # Naming our first service
  cluster         = aws_ecs_cluster.alumni_database_ecs_cluster.id              # Referencing our created Cluster
  task_definition = aws_ecs_task_definition.alumni_database_backend_task.arn    # Referencing the task our service will spin up
  launch_type     = "FARGATE"
  desired_count   = 3 # Setting the number of containers we want deployed to 3

  network_configuration {
    subnets          = ["${aws_default_subnet.default_subnet_b.id}", "${aws_default_subnet.default_subnet_c.id}"]
    assign_public_ip = true                                                # Providing our containers with public IPs
    security_groups  = ["${aws_security_group.service_security_group.id}"] # Setting the security group
  }
}

resource "aws_ecs_service" "alumni_database_frontend" {
  name            = aws_ecs_task_definition.alumni_database_frontend_task.family # Naming our first service
  cluster         = aws_ecs_cluster.alumni_database_ecs_cluster.id               # Referencing our created Cluster
  task_definition = aws_ecs_task_definition.alumni_database_frontend_task.arn    # Referencing the task our service will spin up
  launch_type     = "FARGATE"
  desired_count   = 3 # Setting the number of containers we want deployed to 3

  load_balancer {
    target_group_arn = aws_lb_target_group.target_group.arn # Referencing our target group
    container_name   = aws_ecs_task_definition.alumni_database_frontend_task.family
    container_port   = 80 # Specifying the container port
  }

  network_configuration {
    subnets          = ["${aws_default_subnet.default_subnet_b.id}", "${aws_default_subnet.default_subnet_c.id}"]
    assign_public_ip = true                                                # Providing our containers with public IPs
    security_groups  = ["${aws_security_group.service_security_group.id}"] # Setting the security group
  }
}

resource "aws_ecs_task_definition" "alumni_database_backend_task" {
  family                   = var.backend_task.family # Naming our first task
  container_definitions    = file("${path.module}/task_definitions/${var.backend_task.container_definitions}.json")
  requires_compatibilities = ["FARGATE"]             # Stating that we are using ECS Fargate
  network_mode             = "awsvpc"                # Using awsvpc as our network mode as this is required for Fargate
  memory                   = var.backend_task.memory # Specifying the memory our container requires
  cpu                      = var.backend_task.cpu    # Specifying the CPU our container requires
  execution_role_arn       = aws_iam_role.ecsTaskExecutionRole.arn
}

resource "aws_ecs_task_definition" "alumni_database_frontend_task" {
  family                   = var.frontend_task.family # Naming our first task
  container_definitions    = file("${path.module}/task_definitions/${var.frontend_task.container_definitions}.json")
  requires_compatibilities = ["FARGATE"]              # Stating that we are using ECS Fargate
  network_mode             = "awsvpc"                 # Using awsvpc as our network mode as this is required for Fargate
  memory                   = var.frontend_task.memory # Specifying the memory our container requires
  cpu                      = var.frontend_task.cpu    # Specifying the CPU our container requires
  execution_role_arn       = aws_iam_role.ecsTaskExecutionRole.arn
}

resource "aws_alb" "application_load_balancer" {
  name               = "db-loadbalancer" # Naming our load balancer
  load_balancer_type = "application"
  subnets = [ # Referencing the default subnets
    "${aws_default_subnet.default_subnet_b.id}",
    "${aws_default_subnet.default_subnet_c.id}"
  ]
  # Referencing the security group
  security_groups = ["${aws_security_group.load_balancer_security_group.id}"]
}

# Creating a security group for the load balancer:
resource "aws_security_group" "load_balancer_security_group" {
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allowing traffic in from all sources
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb_target_group" "target_group" {
  name        = "target-group"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_default_vpc.default_vpc.id # Referencing the default VPC
}

resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_alb.application_load_balancer.arn # Referencing our load balancer
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group.arn # Referencing our tagrte group
  }
}

resource "aws_security_group" "service_security_group" {
  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    # Only allowing traffic in from the load balancer security group
    security_groups = ["${aws_security_group.load_balancer_security_group.id}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}