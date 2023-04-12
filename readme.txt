---
- name: Sprawdź wersję do aktualizacji pakietu katello
  hosts: your_host
  become: yes
  tasks:
    - name: Pobierz zainstalowaną wersję pakietu katello
      command:
        cmd: yum list installed katello
        warn: false
      register: yum_output

    - name: Pobierz najnowszą dostępną wersję pakietu katello
      command:
        cmd: yum list available katello --showduplicates | grep katello
        warn: false
      register: yum_latest_version

    - name: Porównaj wersje pakietu
      debug:
        var: yum_output.stdout_lines[0].split()[1] != yum_latest_version.stdout_lines[0].split()[1]
      register: result

    - name: Wyświetl informację o dostępności aktualizacji
      debug:
        var: result.stdout_lines[0]
