#provider_aws: string
 
#parameter: {
    provider: #provider_aws
    frontend_name: string
    route53_hosted_zone_configs?: {
      hosted_zone_id: string
      sub_domain_name: string
    }
}
 
template: {
    components: [
      {
          name: "aws-static-web-application-package"
          type: "aws-static-web-application-package"
          properties: {
            providerRef: {
              name: parameter.provider
            }
            bucket: parameter.frontend_name
            route53_hosted_zone_configs: parameter.route53_hosted_zone_configs
          }
      }
    ]
}
