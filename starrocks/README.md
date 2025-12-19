# 🚀 StarRocks Docker 배포 가이드

이 저장소는 Docker Compose를 사용하여 고가용성(HA)을 지원하는 **StarRocks 클러스터(3 FE, 3 BE)**를 구축하는 환경을 포함하고 있습니다. 모든 노드는 컨테이너 재시작 시에도 통신이 유지되도록 고정 IP 기반으로 설정되어 있습니다.

---

## 1. 클러스터 구성 정보

모든 노드는 외부 네트워크인 `dataplatform-net`을 통해 통신하며, 각 역할에 맞는 고정 IP를 할당받습니다.

### 📋 노드 리스트
| 서비스명 | 역할 | IP 주소 | 호스트명 | 비고 |
| :--- | :--- | :--- | :--- | :--- |
| **starrocks-fe-0** | FE Leader | `10.100.0.21` | starrocks-fe-0 | 클러스터의 시드 노드 |
| **starrocks-fe-1** | FE Follower | `10.100.0.22` | starrocks-fe-1 | 고가용성 지원 |
| **starrocks-fe-2** | FE Follower | `10.100.0.23` | starrocks-fe-2 | 고가용성 지원 |
| **starrocks-be-0** | Backend | `10.100.0.31` | starrocks-be-0 | 데이터 저장 및 연산 |
| **starrocks-be-1** | Backend | `10.100.0.32` | starrocks-be-1 | 데이터 저장 및 연산 |
| **starrocks-be-2** | Backend | `10.100.0.33` | starrocks-be-2 | 데이터 저장 및 연산 |

---

## 2. 사전 준비 사항

배포를 시작하기 전, 호스트 머신에서 다음 설정을 반드시 완료해야 합니다.

### (1) 커널 매개변수 설정 (BE 노드 필수)
StarRocks BE는 많은 수의 메모리 매핑 영역을 사용하므로 호스트 OS의 제한을 늘려야 합니다.
```bash
# 임시 적용 (재부팅 시 초기화)
sudo sysctl -w vm.max_map_count=262144

# 영구 적용
echo "vm.max_map_count=262144" | sudo tee -a /etc/sysctl.conf
```

### (2) 공통 네트워크 생성
컨테이너 간 격리된 통신 환경을 위해 Docker Network를 생성합니다.
```bash
docker network create --driver bridge --subnet=10.100.0.0/16 dataplatform-net
```

---

## 3. 디렉토리 구조
```text
.
├── fe/
│   └── docker-compose.yml     # FE 노드 3대 (Leader 1, Follower 2)
└── be/
    └── docker-compose.yml     # BE 노드 3대
```

---

## 4. 배포 순서

FE 리더가 클러스터의 중심 역할을 하므로, 리더 가동 후 나머지를 기동하는 순서를 권장합니다.

### **Step 1: FE 클러스터 기동**
```bash
cd fe
docker-compose up -d
```
* `starrocks-fe-0`가 먼저 실행되어 리더 역할을 수행합니다.
* `fe-1`, `fe-2`는 설정된 엔트리포인트를 통해 `fe-0`를 바라보며 자동으로 Follower 조인을 시도합니다.

### **Step 2: BE 클러스터 기동**
```bash
cd ../be
docker-compose up -d
```
* 모든 BE 노드는 `starrocks-fe-0`를 시드 노드로 참조하여 클러스터에 등록됩니다.

---

## 5. 상태 확인 방법

MySQL 클라이언트를 통해 FE Leader(`10.100.0.21`)에 접속하여 논리적인 클러스터 상태를 확인합니다.

* **접속 정보**: Port `9030`, ID `root`, Password (기본값 없음)

```sql
-- 1. FE 상태 확인 (3개 노드 Alive 여부 확인)
SHOW FRONTENDS\G

-- 2. BE 상태 확인 (3개 노드 Alive 여부 확인)
SHOW BACKENDS\G
```
> 💡 모든 노드의 **Alive** 항목이 `true`로 표시되어야 정상적으로 클러스터링이 완료된 것입니다.

---

## 6. 주요 관리 설정

* **로그 관리**: 컨테이너 로그 폭증을 방지하기 위해 파일당 `200MB`, 최대 `5개`(총 1GB)로 제한되어 있습니다.
* **데이터 영구 저장 (Persistence)**:
    * **FE**: `./data/fe-n/meta`에 메타데이터 저장
    * **BE**: `./data/be-n/storage`에 실제 데이터 저장
* **환경 설정**:
    * **타임존**: `Asia/Seoul` 적용
    * **메모리 제약**: FE는 Java Heap을 **2GB**(`-Xmx2g`)로 제한 중입니다. BE 노드는 호스트 리소스 상황에 따라 컨테이너 메모리 제한 설정을 권장합니다.

---
📝 **Note**: 클러스터 구성 중 이슈가 발생할 경우 `docker logs -f [컨테이너명]` 명령어로 FE 리더와 조인 시도 중인 노드 간의 통신 로그를 확인하세요.
