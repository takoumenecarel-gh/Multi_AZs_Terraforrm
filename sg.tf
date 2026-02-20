# ALB sg
resource "aws_security_group" "alb_sg" {
  name        = "dev-alb-sg"
  description = "ALB Security Group"
  vpc_id      = aws_vpc.utc_vpc.id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "dev-alb-sg"
    env  = "dev"
    team = "config management"
  }
}

# Bastion host sg
resource "aws_security_group" "bastion_sg" {
  name        = "dev-bastion-sg"
  description = "Bastion Host Security Group"
  vpc_id      = aws_vpc.utc_vpc.id

  ingress {
    description = "SSH from my IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["104.205.171.152/32"] # IP address of my computer/32
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "dev-bastion-sg"
    env  = "dev"
    team = "config management"
  }
}

# App Server sg
resource "aws_security_group" "app_sg" {
  name        = "dev-app-sg"
  description = "App Server Security Group"
  vpc_id      = aws_vpc.utc_vpc.id

  ingress {
    description     = "HTTP from ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  ingress {
    description     = "SSH from Bastion"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "dev-app-sg"
    env  = "dev"
    team = "config management"
  }
}

# Database sg
resource "aws_security_group" "db_sg" {
  name        = "dev-db-sg"
  description = "Database Security Group"
  vpc_id      = aws_vpc.utc_vpc.id

  ingress {
    description     = "MySQL from App Server"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.app_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "dev-db-sg"
    env  = "dev"
    team = "config management"
  }
}