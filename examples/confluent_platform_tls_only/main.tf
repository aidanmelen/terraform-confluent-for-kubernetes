module "confluent_platform_tls_only" {
  source    = "../../"
  namespace = kubernetes_namespace_v1.namespace.metadata[0].name

  confluent_operator = {
    create_namespace = false
  }

  zookeeper = yamldecode(<<-EOF
    spec:
      tls:
        # For this component, Confluent for Kubernete will autogenerate and
        # configure server certs, using a certificate authority specified in
        # the secret `ca-pair-sslcerts`.
        # This same configuration is specified for all other components.
        autoGeneratedCerts: true
    EOF
  )

  kafka = yamldecode(<<-EOF
    spec:
      tls:
        autoGeneratedCerts: true
      listeners:
        internal:
          # The `internal` listener will be TLS enabled.
          tls:
            enabled: true
            # Since no secretRef is specified, the Kafka auto-generated tls
            # configuration specified above will be used for this listener.
      metricReporter:
        enabled: true
        bootstrapEndpoint: kafka:9071
        tls:
          enabled: true
      dependencies:
        zookeeper:
          endpoint: zookeeper.${kubernetes_namespace_v1.namespace.metadata[0].name}.svc.cluster.local:2182
          tls:
            enabled: true
    EOF
  )

  # connect = yamldecode(<<-EOF
  #   spec:
  #     tls:
  #       autoGeneratedCerts: true
  #     dependencies:
  #       kafka:
  #         bootstrapEndpoint: kafka:9071
  #         tls:
  #           enabled: true
  #   EOF
  # )

  # ksqldb = yamldecode(<<-EOF
  #   spec:
  #     tls:
  #       autoGeneratedCerts: true
  #     dependencies:
  #       kafka:
  #         bootstrapEndpoint: kafka:9071
  #         tls:
  #           enabled: true
  #   EOF
  # )

  controlcenter = yamldecode(<<-EOF
    spec:
      tls:
        autoGeneratedCerts: true
      dependencies:
        kafka:
          bootstrapEndpoint: kafka.${kubernetes_namespace_v1.namespace.metadata[0].name}.svc.cluster.local:9071
          tls:
            enabled: true
        schemaRegistry:
          url: https://schemaregistry.${kubernetes_namespace_v1.namespace.metadata[0].name}.svc.cluster.local:8081
          tls:
            enabled: true
        ksqldb:
        - name: ksql
          url: https://ksqldb.${kubernetes_namespace_v1.namespace.metadata[0].name}.svc.cluster.local:8088
          tls:
            enabled: true
        connect:
        - name: connect-dev
          url:  https://connect.${kubernetes_namespace_v1.namespace.metadata[0].name}.svc.cluster.local:8083
          tls:
            enabled: true
    EOF
  )

  # schemaregistry = yamldecode(<<-EOF
  #   spec:
  #     tls:
  #       autoGeneratedCerts: true
  #     dependencies:
  #       kafka:
  #         bootstrapEndpoint: kafka:9071
  #         tls:
  #           enabled: true
  #   EOF
  # )

  # kafkarestproxy = yamldecode(<<-EOF
  #   spec:
  #     tls:
  #       autoGeneratedCerts: true
  #     dependencies:
  #       schemaRegistry:
  #         url: https://schemaregistry.${kubernetes_namespace_v1.namespace.metadata[0].name}.svc.cluster.local:8081
  #         tls:
  #           enabled: true
  #   EOF
  # )
}

module "kafka_rest_class" {
  source    = "../../modules/kafka_rest_class"
  name      = "default"
  namespace = kubernetes_namespace_v1.namespace.metadata[0].name
}