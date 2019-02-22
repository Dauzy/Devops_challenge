# DevOps Coding Challenge

We need to create a Web Server Infrastructure. The infrastructure must have a vpc, two subnets, one prublic subnet and the other private subnet, a load balancer which is publicly available on the internet and the internet gateway.

![Alt text](images/infra.png?raw=true "Title")

* It includes a VPC with an IPv4 CIDR of 10.0.0.0/16

* It includes a public subnet with an IPv4 CIDR of 10.0.1.0/24

* It includes a private subnet with an IPv4 CIDR of 10.0.2.0/24

* It includes a Load Balancer (LB)

* It includes two Web Servers that are attached to the LB

* The Web Servers include a small “Hello World” Web App. The functionality of this Web App is not part of this challenge, it just needs to return something when a HTTP call is made to the Servers

* The LB,  which is publicly available on the internet, serves the Web App running on the Web Servers

* The Web Servers do not allow to access the Web App from the public Internet, only the LB has access

* There is a deployment script (or similar) to update the Web App on all Web Servers

* Feel free to add any Security Groups, NACLs or any other component necessary to make the application work


# Setup

To create infrastructure we need the following the next steps:

1. Is necessary change value of key_path variable for access to own instance.

  ```
  #variables.tf

  variable "key_path" {
    description = "SSH key path"
    default = "/path/to/your/public_key"
  }
  ```

2. Export the AWS credentials variables as an envrionment variables:
  ```bash
  export AWS_ACCESS_KEY_ID=”YOUR ACCESS KEY ID”
  export AWS_SECRET_ACCESS_KEY=”YOUR SECRET ACCESS KEY”
  ```

3. Finally type "terraform plan" and we see how terraform plans the resources. To create the infrastructure type “terraform apply“.
  ```bash
  $ terraform plan
  ...
  $ terraform apply
  ```

Now, we can use the DNS name of our load balancer to visit web app and see the results.
