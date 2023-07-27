provider "aws" {
  region = "ap-northeast-2" 
}

resource "aws_vpc" "team01" {
  cidr_block = "10.1.0.0/16"  

  tags = {
    Name = "team01-vpc"
  }
}


resource "aws_subnet" "team01" {
  count             = 6
  vpc_id            = aws_vpc.team01.id
  cidr_block        = "10.1.${count.index + 1}.0/24"  # 서브넷의 CIDR 블록을 "10.1.1.0/24"부터 "10.1.6.0/24"까지 순차적으로 설정합니다.
  availability_zone = element(["ap-northeast-2a", "ap-northeast-2b"], count.index % 2)  # 서브넷을 가용 영역 "ap-northeast-2a"와 "ap-northeast-2b"로 번갈아가면서 생성합니다.

  tags = {
    Name = "team01-subnet-${count.index}"
  }
}

resource "aws_internet_gateway" "team01" {
  vpc_id = aws_vpc.team01.id
  
  tags = {
    Name = "team01-igw"
  }
}

resource "aws_security_group" "team01-web" {
  name        = "team01-security-web-group"
  description = "Team01 security web group"

  vpc_id = aws_vpc.team01.id

  # 인바운드 트래픽 규칙 추가 (HTTP 허용)
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # 인바운드 트래픽 규칙 추가 (SSH 허용)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # 아웃바운드 트래픽 규칙 추가 (모든 트래픽 허용)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "team01-aurora" {
  name        = "team01-security-aurora-group"
  description = "Team01 security aurora group"

  vpc_id = aws_vpc.team01.id

  # 인바운드 트래픽 규칙 추가 (HTTP 허용)
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # 아웃바운드 트래픽 규칙 추가 (모든 트래픽 허용)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_nat_gateway" "team01" {
  allocation_id = aws_eip.team01.id
  subnet_id     = aws_subnet.team01[0].id  # 첫 번째 서브넷을 사용하여 NAT 게이트웨이를 생성합니다.

  tags = {
    Name = "team01-nat-gateway"
  }
}

resource "aws_eip" "team01" {
#  vpc = true

  tags = {
    Name = "team01-eip"
  }
}

##-- 라우팅테이블 생성 (IGW)
resource "aws_route_table" "team01-igw" {
  vpc_id = aws_vpc.team01.id

  tags = {
    Name = "team01-igw-route-table"
  }
}

# 인터넷 게이트웨이와 연결하는 라우팅 테이블 라우트 추가
resource "aws_route" "team01_internet_gateway_route" {
  route_table_id         = aws_route_table.team01-igw.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.team01.id
}

##-- 라우팅 연결
resource "aws_route_table_association" "team01-sub-public" {
  count          = 2
  subnet_id      = aws_subnet.team01[count.index].id
  route_table_id = aws_route_table.team01-igw.id
}



##-- 라우팅테이블 생성 (NGW)
resource "aws_route_table" "team01-ngw" {
  vpc_id = aws_vpc.team01.id

  tags = {
    Name = "team01-ngw-route-table"
  }
}

# NAT 게이트웨이와 연결하는 라우팅 테이블 라우트 추가
resource "aws_route" "team01_nat_gateway_route" {
  route_table_id         = aws_route_table.team01-ngw.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.team01.id
}


##-- 라우팅 연결
resource "aws_route_table_association" "team01-sub-private" {
  count          = 4
  subnet_id      = aws_subnet.team01[count.index+2].id
  route_table_id = aws_route_table.team01-ngw.id
}

# Transit Gateway 1 생성
resource "aws_ec2_transit_gateway" "transit_gateway_1" {
  description = "Transit Gateway 1 for Seoul and Ohio"
  amazon_side_asn = 64512
}

#resource "aws_db_subnet_group" "team01" {
#  name       = "team01-db-subnet-group"
#  #subnet_ids = ["subnet-12345678", "subnet-87654321"]  # Subnet ID를 적절하게 변경해 주세요.
#  subnet_ids = [aws_subnet.team01[4].id, aws_subnet.team01[5].id]
#}

#resource "aws_rds_cluster" "team01" {
#  cluster_identifier      = "team01-cluster"
#  engine                  = "aurora-mysql"  # Aurora MySQL을 사용하려면 이 값을 사용합니다.
#  engine_version          = "5.7.mysql_aurora.2.11.3"
#  database_name           = "team01_db"
#  master_username         = "admin"
#  master_password         = "adminpass"  # 복잡한 비밀번호로 변경해 주세요.
#  port                    = 3306
#  db_subnet_group_name    = aws_db_subnet_group.team01.name
#  vpc_security_group_ids  = [aws_security_group.team01-aurora.id]
#  instance {
#    instance_class = "db.r5.large"  # 원하는 인스턴스 유형으로 변경해 주세요.
#  }
#}

#output "cluster_endpoint" {
#  value = aws_rds_cluster.team01.endpoint
#}
