output "address" {
  value = "${aws_route53_record.btp.name}"
}

output "ip" {
  value = "${aws_instance.web.public_ip}"
}
