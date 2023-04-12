#test
---
- name: Wyszukaj i sprawdź wersję pakietu katello
  hosts: your_host
  become: yes
  tasks:
    - name: Wyszukaj pakiet katello
      yum:
        list: katello
      register: yum_output

    - name: Wyświetl aktualną wersję pakietu
      debug:
        var: yum_output.packages[0].version
