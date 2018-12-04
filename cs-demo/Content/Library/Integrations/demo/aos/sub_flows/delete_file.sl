namespace: Integrations.demo.aos.sub_flows
flow:
  name: delete_file
  inputs:
    - host: 10.0.46.46
    - username: root
    - password: admin@123
    - filename: install_postgres.sh
  workflow:
    - delete_file:
        do:
          io.cloudslang.base.ssh.ssh_command:
            - host: '${host}'
            - command: "${'cd '+get_sp('script_location')+' && rm -f '+filename}"
            - username: '${username}'
            - password:
                value: '${password}'
                sensitive: true
        navigate:
          - SUCCESS: SUCCESS
          - FAILURE: on_failure
  results:
    - FAILURE
    - SUCCESS
extensions:
  graph:
    steps:
      delete_file:
        x: 64
        y: 51
        navigate:
          3106557b-69a2-f3f8-a6be-22832118798a:
            targetId: c3aa1cd8-26a3-0645-5315-851a8bee4e3a
            port: SUCCESS
    results:
      SUCCESS:
        c3aa1cd8-26a3-0645-5315-851a8bee4e3a:
          x: 286
          y: 42
