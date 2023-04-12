---
- name: Sprawdź wersję do aktualizacji pakietu katello
  hosts: your_host
  become: yes
  tasks:
    - name: Pobierz zainstalowaną wersję pakietu katello
      yum:
        list: katello
        disable_gpg_check: yes
      register: yum_output

    - name: Pobierz najnowszą dostępną wersję pakietu katello
      yum:
        list: katello
        disable_gpg_check: yes
        showduplicates: yes
      register: yum_latest_version

    - name: Porównaj wersje pakietu
      debug:
        var: yum_output.packages[0].version != yum_latest_version.packages[0].version
      register: result

    - name: Wyświetl informację o dostępności aktualizacji
      debug:
        var: result.stdout_lines[0]

