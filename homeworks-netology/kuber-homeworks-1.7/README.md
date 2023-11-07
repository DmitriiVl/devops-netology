# Ответы на задания kuber-homeworks-1.7 

### Цель задания

В тестовой среде Kubernetes нужно создать PV и продемострировать запись и хранение файлов.

------

### Чеклист готовности к домашнему заданию

1. Установленное K8s-решение (например, MicroK8S).
2. Установленный локальный kubectl.
3. Редактор YAML-файлов с подключенным GitHub-репозиторием.

------

### Дополнительные материалы для выполнения задания

1. [Инструкция по установке NFS в MicroK8S](https://microk8s.io/docs/nfs). 
2. [Описание Persistent Volumes](https://kubernetes.io/docs/concepts/storage/persistent-volumes/). 
3. [Описание динамического провижининга](https://kubernetes.io/docs/concepts/storage/dynamic-provisioning/). 
4. [Описание Multitool](https://github.com/wbitt/Network-MultiTool).

------

### Задание 1

**Что нужно сделать**

Создать Deployment приложения, использующего локальный PV, созданный вручную.

1. Создать Deployment приложения, состоящего из контейнеров busybox и multitool.
2. Создать PV и PVC для подключения папки на локальной ноде, которая будет использована в поде.
3. Продемонстрировать, что multitool может читать файл, в который busybox пишет каждые пять секунд в общей директории. 
4. Удалить Deployment и PVC. Продемонстрировать, что после этого произошло с PV. Пояснить, почему.
5. Продемонстрировать, что файл сохранился на локальном диске ноды. Удалить PV.  Продемонстрировать что произошло с файлом после удаления PV. Пояснить, почему.
5. Предоставить манифесты, а также скриншоты или вывод необходимых команд.

------

### Задание 2

**Что нужно сделать**

Создать Deployment приложения, которое может хранить файлы на NFS с динамическим созданием PV.

1. Включить и настроить NFS-сервер на MicroK8S.
2. Создать Deployment приложения состоящего из multitool, и подключить к нему PV, созданный автоматически на сервере NFS.
3. Продемонстрировать возможность чтения и записи файла изнутри пода. 
4. Предоставить манифесты, а также скриншоты или вывод необходимых команд.

------

### Ответ на Задание 1

Готовим манифесты для всех необходимых сущностей:  

<details>
<summary>Deployment for busybox and multitool</summary>

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: dep-pv-pvc
  namespace: hw1-7
spec:
  replicas: 1
  selector:
    matchLabels:
      app: busybox-multitool
  template:
    metadata:
      labels:
        app: busybox-multitool
    spec:
      volumes:
      - name: volume-app-busybox-multitool
        persistentVolumeClaim:
          claimName: pvc-app-busybox-multitool
      containers:
      - name: busybox
        image: busybox
        resources:
          limits:
            memory: "64Mi"
            cpu: "250m"
        command: ['sh', '-c', "sleep 10; while true; do (echo '====================================='; date; ping -c 3 ya.ru) >> /mnt/share-folder/doc.log; sleep 10; done"]
        volumeMounts:
          - name: volume-app-busybox-multitool
            mountPath: /mnt/share-folder
      - name: multitool
        image: wbitt/network-multitool
        resources:
          limits:
            memory: "64Mi"
            cpu: "250m"
        volumeMounts:
          - name: volume-app-busybox-multitool
            mountPath: /mnt/share-folder
```

</details>

<details>
<summary>PV for app</summary>

```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv-local-volume
  namespace: hw1-7
spec:
  capacity:
    storage: 1Gi
  volumeMode: Filesystem
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  hostPath:
    path: /mnt/share-folder
```

</details>

<details>
<summary>PVC for app</summary>

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvc-app-busybox-multitool
  namespace: hw1-7
spec:
  storageClassName: ""
  resources:
    requests:
      storage: 1Gi
  volumeMode: Filesystem
  accessModes:
    - ReadWriteOnce
  volumeName: pv-local-volume
```

</details>

Проверяем, что все запустилось, а также доступность файла из PV для контейнера с multitool:

```
dmivlad@Ubuntu-Kuber:/mnt/share-folder$ kubectl get pods

NAME                          READY   STATUS    RESTARTS        AGE

dep-pv-pvc-76dc596896-sk5qq   2/2     Running   2 (8m56s ago)   174m

dmivlad@Ubuntu-Kuber:/mnt/share-folder$ kubectl get pv

NAME              CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM                             STORAGECLASS   REASON   AGE

pv-local-volume   1Gi        RWO            Retain           Bound    hw1-7/pvc-app-busybox-multitool                           3h

dmivlad@Ubuntu-Kuber:/mnt/share-folder$ kubectl get pvc

NAME                        STATUS   VOLUME            CAPACITY   ACCESS MODES   STORAGECLASS   AGE

pvc-app-busybox-multitool   Bound    pv-local-volume   1Gi        RWO                           178m

dmivlad@Ubuntu-Kuber:/mnt/share-folder$ kubectl exec dep-pv-pvc-76dc596896-sk5qq -it -c multitool -- bin/bash

dep-pv-pvc-76dc596896-sk5qq:/# tail -n 10 /mnt/share-folder/doc.log 

=====================================

Mon Nov  6 13:18:01 UTC 2023

PING ya.ru (5.255.255.242): 56 data bytes

64 bytes from 5.255.255.242: seq=0 ttl=243 time=64.744 ms

64 bytes from 5.255.255.242: seq=1 ttl=243 time=82.946 ms

64 bytes from 5.255.255.242: seq=2 ttl=243 time=50.395 ms



--- ya.ru ping statistics ---

3 packets transmitted, 3 packets received, 0% packet loss

round-trip min/avg/max = 50.395/66.028/82.946 ms

dep-pv-pvc-76dc596896-sk5qq:/# 

```

Удаляем Deployment и PVC и видим, что доступ к PV остается:  

```
dmivlad@Ubuntu-Kuber:/mnt/share-folder$ kubectl delete deployment dep-pv-pvc

deployment.apps "dep-pv-pvc" deleted

dmivlad@Ubuntu-Kuber:/mnt/share-folder$ kubectl delete pvc pvc-app-busybox-multitool

persistentvolumeclaim "pvc-app-busybox-multitool" deleted

dmivlad@Ubuntu-Kuber:/mnt/share-folder$ tail -n 10 doc.log 

=====================================

Mon Nov  6 13:22:18 UTC 2023

PING ya.ru (77.88.55.242): 56 data bytes

64 bytes from 77.88.55.242: seq=0 ttl=241 time=113.584 ms

64 bytes from 77.88.55.242: seq=1 ttl=241 time=150.765 ms

64 bytes from 77.88.55.242: seq=2 ttl=241 time=43.110 ms



--- ya.ru ping statistics ---

3 packets transmitted, 3 packets received, 0% packet loss

round-trip min/avg/max = 43.110/102.486/150.765 ms

```

Теперь можно удалить и PV, однако доступ на хост-машине к папке сохранится. Это происходит из-за указания параметра *persistentVolumeReclaimPolicy: Retain*, который не предусматривает автоматического удаления ресурсов из внешних провайдеров (в нашем случае локальной папки на хост-машине). Папку в случае такой необходимости придется удалять вручную. 

------


### Ответ на Задание 2  

Включаем поддерку NFS в Microk8s и устанавливаем необходимые пакеты на хост-машину следующим списком команд:  

```
sudo microk8s enable community
sudo microk8s status
sudo microk8s enable nfs
sudo apt update && sudo apt install -y nfs
```

Готовим манифест для Deployment с multitool и манифест PVC:  

<details>
<summary>Deployment and PVC manifests for NFS testing</summary>

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvc-app-multitool-nfs
  namespace: hw1-7  
spec:
  storageClassName: nfs
  resources:
    requests:
      storage: 1Gi
#  volumeMode: Filesystem
  accessModes:
    - ReadWriteOnce
#  volumeName: pv-local-volume

---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: dep-multitool-nfs
  namespace: hw1-7
spec:
  replicas: 1
  selector:
    matchLabels:
      app: multitool-nfs
  template:
    metadata:
      labels:
        app: multitool-nfs
    spec:
      volumes:
      - name: volume-multitool-nfs
        persistentVolumeClaim:
          claimName: pvc-app-multitool-nfs
      containers:
      - name: multitool
        image: wbitt/network-multitool
        resources:
          limits:
            memory: "64Mi"
            cpu: "250m"
        volumeMounts:
          - name: volume-multitool-nfs
            mountPath: /mnt/nfs         
```

</details>

Проверяем, что все поднялось и работает:  

```
dmivlad@Ubuntu-Kuber:~/Documents/Kubernetes_HW/HW_1.7$ kubectl get pods

NAME                                 READY   STATUS    RESTARTS   AGE

dep-multitool-nfs-5cdccff969-nlbjc   1/1     Running   0          7m2s

dmivlad@Ubuntu-Kuber:~/Documents/Kubernetes_HW/HW_1.7$ kubectl get pvc

NAME                    STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   AGE

pvc-app-multitool-nfs   Bound    pvc-354e0d2c-16aa-4191-b84b-5fd89e42da95   1Gi        RWO            nfs            7m8s

dmivlad@Ubuntu-Kuber:~/Documents/Kubernetes_HW/HW_1.7$ kubectl get pv

NAME                                       CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM                                                  STORAGECLASS   REASON   AGE

data-nfs-server-provisioner-0              1Gi        RWO            Retain           Bound    nfs-server-provisioner/data-nfs-server-provisioner-0                           27m

pvc-354e0d2c-16aa-4191-b84b-5fd89e42da95   1Gi        RWO            Delete           Bound    hw1-7/pvc-app-multitool-nfs                            nfs                     7m10s

dmivlad@Ubuntu-Kuber:~/Documents/Kubernetes_HW/HW_1.7$ 


```

Демонстрируем возможность записи и чтения файла изнутри POD:  

```
dep-multitool-nfs-5cdccff969-nlbjc:/# cd mnt/nfs

dep-multitool-nfs-5cdccff969-nlbjc:/mnt/nfs# cat settings.ini 

dep-multitool-nfs-5cdccff969-nlbjc:/mnt/nfs# echo "I have done this exercise!" > settings.ini 

dep-multitool-nfs-5cdccff969-nlbjc:/mnt/nfs# cat settings.ini 

I have done this exercise!

```

------
