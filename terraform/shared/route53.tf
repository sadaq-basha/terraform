resource "aws_route53_zone" "live_smart_io" {
  name = "live-smart.io."

  lifecycle {
    ignore_changes = [
      comment,
    ]
  }
}

resource "aws_route53_record" "live_smart_io" {
  name = "live-smart.io."
  type = "A"
  ttl  = 600
  records = [
    "3.113.11.143"
  ]
  zone_id = aws_route53_zone.live_smart_io.id
}

resource "aws_route53_record" "live_smart_io2" {
  name = "live-smart.io."
  type = "NS"
  ttl  = 172800
  records = [
    "ns-498.awsdns-62.com.",
    "ns-1239.awsdns-26.org.",
    "ns-827.awsdns-39.net.",
    "ns-2011.awsdns-59.co.uk."
  ]
  zone_id = aws_route53_zone.live_smart_io.id
}

resource "aws_route53_record" "live_smart_io3" {
  name = "live-smart.io."
  type = "SOA"
  ttl  = 900
  records = [
    "ns-498.awsdns-62.com. awsdns-hostmaster.amazon.com. 1 7200 900 1209600 86400"
  ]
  zone_id = aws_route53_zone.live_smart_io.id
}

resource "aws_route53_record" "live_smart_io4" {
  name = "jenkins.2c98ao.live-smart.io."
  type = "CNAME"
  ttl  = 3600
  records = [
    "a208451dcc7db11e99ab00e80795c4d8-235051194.ap-northeast-1.elb.amazonaws.com."
  ]
  zone_id = aws_route53_zone.live_smart_io.id
}

resource "aws_route53_record" "live_smart_io5" {
  name = "_12e9b2ee25fbf4000c0f16bf7a272b35.live-smart.io."
  type = "CNAME"
  ttl  = 300
  records = [
    "_491d427288a975b7d8fd712d8c2f497c.auiqqraehs.acm-validations.aws."
  ]
  zone_id = aws_route53_zone.live_smart_io.id
}

resource "aws_route53_record" "live_smart_io6" {
  name = "_domainconnect.live-smart.io."
  type = "CNAME"
  ttl  = 3600
  records = [
    "_domainconnect.gd.domaincontrol.com."
  ]
  zone_id = aws_route53_zone.live_smart_io.id
}

resource "aws_route53_record" "live_smart_io7" {
  name = "api-oauth-sandbox.live-smart.io."
  type = "A"
  alias {
    name                   = "d2l56z1q3h8n4v.cloudfront.net."
    zone_id                = "Z2FDTNDATAQYW2"
    evaluate_target_health = false
  }
  zone_id = aws_route53_zone.live_smart_io.id
}

resource "aws_route53_record" "live_smart_io8" {
  name = "api-sandbox.live-smart.io."
  type = "A"
  alias {
    name                   = "d27fnk2th5cj5f.cloudfront.net."
    zone_id                = "Z2FDTNDATAQYW2"
    evaluate_target_health = false
  }
  zone_id = aws_route53_zone.live_smart_io.id
}

resource "aws_route53_record" "live_smart_io9" {
  name = "controlweb-dev.live-smart.io."
  type = "CNAME"
  ttl  = 1800
  records = [
    "a208451dcc7db11e99ab00e80795c4d8-235051194.ap-northeast-1.elb.amazonaws.com."
  ]
  zone_id = aws_route53_zone.live_smart_io.id
}

resource "aws_route53_record" "live_smart_io10" {
  name = "controlweb.live-smart.io."
  type = "CNAME"
  ttl  = 1800
  records = [
    "a4d448de3d89211e986fd0680738cf7e-1640333889.ap-northeast-1.elb.amazonaws.com."
  ]
  zone_id = aws_route53_zone.live_smart_io.id
}

resource "aws_route53_record" "live_smart_io11" {
  name = "dashboard-api.live-smart.io."
  type = "CNAME"
  ttl  = 3600
  records = [
    "a4d448de3d89211e986fd0680738cf7e-1640333889.ap-northeast-1.elb.amazonaws.com."
  ]
  zone_id = aws_route53_zone.live_smart_io.id
}

resource "aws_route53_record" "live_smart_io12" {
  name = "am-2c98ao.dev.live-smart.io."
  type = "CNAME"
  ttl  = 3600
  records = [
    "a208451dcc7db11e99ab00e80795c4d8-235051194.ap-northeast-1.elb.amazonaws.com."
  ]
  zone_id = aws_route53_zone.live_smart_io.id
}

resource "aws_route53_record" "live_smart_io13" {
  name = "dashboard-api.dev.live-smart.io."
  type = "CNAME"
  ttl  = 3600
  records = [
    "a208451dcc7db11e99ab00e80795c4d8-235051194.ap-northeast-1.elb.amazonaws.com."
  ]
  zone_id = aws_route53_zone.live_smart_io.id
}

resource "aws_route53_record" "live_smart_io14" {
  name = "grafana-2c98ao.dev.live-smart.io."
  type = "CNAME"
  ttl  = 3600
  records = [
    "a208451dcc7db11e99ab00e80795c4d8-235051194.ap-northeast-1.elb.amazonaws.com."
  ]
  zone_id = aws_route53_zone.live_smart_io.id
}

resource "aws_route53_record" "live_smart_io15" {
  name = "kubeops-2c98ao.dev.live-smart.io."
  type = "CNAME"
  ttl  = 3600
  records = [
    "a208451dcc7db11e99ab00e80795c4d8-235051194.ap-northeast-1.elb.amazonaws.com."
  ]
  zone_id = aws_route53_zone.live_smart_io.id
}

resource "aws_route53_record" "live_smart_io16" {
  name = "mailhog-2c98ao.dev.live-smart.io."
  type = "CNAME"
  ttl  = 3600
  records = [
    "a208451dcc7db11e99ab00e80795c4d8-235051194.ap-northeast-1.elb.amazonaws.com."
  ]
  zone_id = aws_route53_zone.live_smart_io.id
}

resource "aws_route53_record" "live_smart_io17" {
  name = "prometheus-2c98ao.dev.live-smart.io."
  type = "CNAME"
  ttl  = 3600
  records = [
    "a208451dcc7db11e99ab00e80795c4d8-235051194.ap-northeast-1.elb.amazonaws.com."
  ]
  zone_id = aws_route53_zone.live_smart_io.id
}

resource "aws_route53_record" "live_smart_io18" {
  name = "rabbitmq-2c98ao.dev.live-smart.io."
  type = "CNAME"
  ttl  = 3600
  records = [
    "a208451dcc7db11e99ab00e80795c4d8-235051194.ap-northeast-1.elb.amazonaws.com."
  ]
  zone_id = aws_route53_zone.live_smart_io.id
}

resource "aws_route53_record" "live_smart_io19" {
  name = "ls-b2b-api.live-smart.io."
  type = "CNAME"
  ttl  = 3600
  records = [
    "a4d448de3d89211e986fd0680738cf7e-1640333889.ap-northeast-1.elb.amazonaws.com."
  ]
  zone_id = aws_route53_zone.live_smart_io.id
}

resource "aws_route53_record" "live_smart_io20" {
  name = "_oktaverification.lsapitest-okta.live-smart.io."
  type = "TXT"
  ttl  = 300
  records = [
    "5a999399026147b4a1cb8acbd83d6248"
  ]
  zone_id = aws_route53_zone.live_smart_io.id
}

resource "aws_route53_record" "live_smart_io21" {
  name = "mqtt-b2b.live-smart.io."
  type = "CNAME"
  ttl  = 3600
  records = [
    "ac7a04dd9e10f11e986fd0680738cf7e-1030313949.ap-northeast-1.elb.amazonaws.com."
  ]
  zone_id = aws_route53_zone.live_smart_io.id
}

resource "aws_route53_record" "live_smart_io22" {
  name = "am-2c98ao.prd.live-smart.io."
  type = "CNAME"
  ttl  = 3600
  records = [
    "a4d448de3d89211e986fd0680738cf7e-1640333889.ap-northeast-1.elb.amazonaws.com."
  ]
  zone_id = aws_route53_zone.live_smart_io.id
}

resource "aws_route53_record" "live_smart_io23" {
  name = "grafana-2c98ao.prd.live-smart.io."
  type = "CNAME"
  ttl  = 3600
  records = [
    "a4d448de3d89211e986fd0680738cf7e-1640333889.ap-northeast-1.elb.amazonaws.com."
  ]
  zone_id = aws_route53_zone.live_smart_io.id
}

resource "aws_route53_record" "live_smart_io24" {
  name = "kubeops-2c98ao.prd.live-smart.io."
  type = "CNAME"
  ttl  = 3600
  records = [
    "a4d448de3d89211e986fd0680738cf7e-1640333889.ap-northeast-1.elb.amazonaws.com."
  ]
  zone_id = aws_route53_zone.live_smart_io.id
}

resource "aws_route53_record" "live_smart_io25" {
  name = "mailhog-2c98ao.prd.live-smart.io."
  type = "CNAME"
  ttl  = 3600
  records = [
    "a4d448de3d89211e986fd0680738cf7e-1640333889.ap-northeast-1.elb.amazonaws.com."
  ]
  zone_id = aws_route53_zone.live_smart_io.id
}

resource "aws_route53_record" "live_smart_io26" {
  name = "prometheus-2c98ao.prd.live-smart.io."
  type = "CNAME"
  ttl  = 3600
  records = [
    "a4d448de3d89211e986fd0680738cf7e-1640333889.ap-northeast-1.elb.amazonaws.com."
  ]
  zone_id = aws_route53_zone.live_smart_io.id
}

resource "aws_route53_record" "live_smart_io27" {
  name = "rabbitmq-2c98ao.prd.live-smart.io."
  type = "CNAME"
  ttl  = 3600
  records = [
    "a4d448de3d89211e986fd0680738cf7e-1640333889.ap-northeast-1.elb.amazonaws.com."
  ]
  zone_id = aws_route53_zone.live_smart_io.id
}

resource "aws_route53_record" "live_smart_io28" {
  name = "jenkins.test.live-smart.io."
  type = "CNAME"
  ttl  = 300
  records = [
    "a9f04c15fa0b111eaa10406af2bb9193-1783837324.ap-northeast-1.elb.amazonaws.com"
  ]
  zone_id = aws_route53_zone.live_smart_io.id
}

resource "aws_route53_record" "live_smart_io29" {
  name = "kubeops-2c98ao.test.live-smart.io."
  type = "CNAME"
  ttl  = 300
  records = [
    "a9f04c15fa0b111eaa10406af2bb9193-1783837324.ap-northeast-1.elb.amazonaws.com"
  ]
  zone_id = aws_route53_zone.live_smart_io.id
}

resource "aws_route53_record" "live_smart_io30" {
  name = "www.live-smart.io."
  type = "CNAME"
  ttl  = 3600
  records = [
    "live-smart.io."
  ]
  zone_id = aws_route53_zone.live_smart_io.id
}
