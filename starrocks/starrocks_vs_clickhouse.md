## 💎 왜 StarRocks인가? (OLAP 경쟁력)

StarRocks는 현대적인 데이터 스택에서 **실시간 분석**과 **고성능 MPP(Massively Parallel Processing)**를 결합한 차세대 OLAP 엔진입니다. 특히 CDC 파이프라인(MariaDB -> Kafka -> StarRocks)에서 타 솔루션 대비 독보적인 이점을 제공합니다.

### 1. StarRocks의 핵심 장점
* **초고성능 벡터화 엔진**: CPU의 SIMD 명령어를 극대화하여 처리 속도를 높였으며, CBO(Cost-Based Optimizer)를 통해 복잡한 쿼리도 최적의 경로로 실행합니다.
* **Primary Key 모델 (Real-time Upsert)**: 성능 저하 없이 실시간으로 데이터를 반영합니다.
* **MySQL 프로토콜 호환**: 별도의 학습 없이 기존 MySQL 클라이언트나 BI 도구(Superset, Tableau 등)를 그대로 사용할 수 있습니다.
* **유연한 스케일 아웃**: FE와 BE가 분리된 구조로, 데이터 증가량에 맞춰 선형적으로 성능을 확장할 수 있습니다.

---

### 2. StarRocks vs ClickHouse 비교

많은 엔지니어가 고민하는 ClickHouse와 비교했을 때, StarRocks는 특히 **운영 편의성**과 **복잡한 쿼리 처리** 면에서 압도적입니다.


| 비교 항목 | StarRocks (승자) | ClickHouse |
| :--- | :--- | :--- |
| **Join 성능** | **압도적**. Multi-table Join 및 Shuffle Join 최적화로 복잡한 분석 가능 | 대량의 데이터 Join 시 메모리 부족 및 속도 저하 발생 빈번 |
| **데이터 수정 (Update/Delete)** | **Primary Key 모델**로 실시간 Upsert 완벽 지원 (CDC 최적화) | `ReplacingMergeTree` 등 간접적인 방식 사용, 실시간 반영 지연 존재 |
| **SQL 표준** | **표준 SQL** 및 MySQL 프로토콜 100% 지원 | 자체 SQL 문법(ClickHouse SQL) 사용으로 학습 곡선 존재 |
| **아키텍처/관리** | 간단한 구조. ZooKeeper 등 **외부 의존성 없음** | 클러스터 관리를 위해 ZooKeeper 또는 ClickHouse Keeper 필수 |
| **동시성 (Concurrency)** | 수천 명의 사용자가 동시에 쿼리하는 **고가용성 환경**에 강함 | 단일 대형 쿼리에는 강하나, 높은 동시성 환경에서는 취약 |
