output "security_group_ids" {
  value = {
    main   = yandex_vpc_security_group.k8s_main.id
    public = yandex_vpc_security_group.k8s_public.id
  }
}