namespace: Integrations.demo.aos.sub_flows
flow:
  name: initialize_artifact
  inputs:
    - host
    - username
    - password
    - artifact_url:
        required: false
    - script_url
    - parameters:
        required: false
  workflow:
    - string_equals:
        do:
          io.cloudslang.base.strings.string_equals:
            - first_string: '${artifact_url}'
        navigate:
          - SUCCESS: copy_script
          - FAILURE: copy_artifact
    - copy_artifact:
        do:
          Integrations.demo.aos.sub_flows.remote_copy:
            - host: '${host}'
            - username: '${username}'
            - url: '${artifact_url}'
            - password: '${password}'
        publish:
          - artifact_name: '${filename}'
        navigate:
          - FAILURE: copy_script
    - copy_script:
        do:
          Integrations.demo.aos.sub_flows.remote_copy:
            - host: '${host}'
            - username: '${username}'
            - url: '${script_url}'
            - password: '${password}'
        publish: []
        navigate:
          - FAILURE: on_failure
          - SUCCESS: execute_script
    - execute_script:
        do:
          io.cloudslang.base.ssh.ssh_command:
            - host: '${host}'
            - command: "${'cd '+get_sp('script_location')+' && chmod 755 '+script_name+' && sh '+script_name+' '+get('artifact_name', '')+' '+get('parameters', '')+' > '+script_name+'.log'}"
            - username: '${username}'
            - password:
                value: '${password}'
                sensitive: true
        publish:
          - command_return_code
        navigate:
          - SUCCESS: delete_file
          - FAILURE: on_failure
    - delete_file:
        do:
          Integrations.demo.aos.sub_flows.delete_file:
            - host: '${host}'
            - username: '${username}'
            - password: '${password}'
            - filename: '${artifact_name}'
        navigate:
          - FAILURE: on_failure
          - SUCCESS: is_true
    - is_true:
        do:
          io.cloudslang.base.utils.is_true:
            - bool_value: "${str(command_return_code == '0')}"
        navigate:
          - 'TRUE': SUCCESS
          - 'FALSE': FAILURE
  results:
    - FAILURE
    - SUCCESS
extensions:
  graph:
    steps:
      string_equals:
        x: 353
        y: 1
      copy_artifact:
        x: 132
        y: 109
      copy_script:
        x: 368
        y: 140
      execute_script:
        x: 162
        y: 260
      delete_file:
        x: 350
        y: 283
      is_true:
        x: 590
        y: 99
        navigate:
          b73e24bf-a881-4a39-23e9-3a504b0c5718:
            targetId: c46962c6-33d9-f878-21d5-c33b44e439dc
            port: 'TRUE'
          1d0e2c26-ec03-75f9-5cc3-29a2f61d68f5:
            targetId: 16a9bf26-bbe7-a5bb-b0ab-28f8d44c9fcb
            port: 'FALSE'
    results:
      SUCCESS:
        c46962c6-33d9-f878-21d5-c33b44e439dc:
          x: 526
          y: 250
      FAILURE:
        16a9bf26-bbe7-a5bb-b0ab-28f8d44c9fcb:
          x: 635
          y: 216
