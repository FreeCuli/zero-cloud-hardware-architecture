# FREECULI ZC-CORE — M1–M10 Uyumluluk Matrisi ve Dosya Bazlı Değişiklik Planı
## (M1–M10 Invariant Compatibility Matrix & Documentation Remediation Plan)

**Belge Kimliği:** ZC-CORE-EVIDENCE-M1-M10-COMPAT-PLAN-01  
**Tarih:** 20 Ekim 2026  
**Revizyon:** 1.0.0 (Hibrit Mimari Yönetişim İncelemesi)  
**Hedef Depo:** `FreeCuli/zero-cloud-hardware-architecture`  
**Çalışma Dalı:** `gate-c/formal-scope-audit`  
**Yönetişim Statüsü:** **Gate C: PARTIAL / QUALIFIED** | **Gate D: UNVERIFIED** | **DO NOT MERGE** | **RELEASE BLOCKED**  

---

## 1. M1–M10 Değişmezleri Uyumluluk Matrisi (STRICT vs. HYBRID)

Tüm ZC-CORE metodolojisinin DNA'sını oluşturan M1–M10 kuralları, **STRICT** ve **HYBRID** profilleri karşısında bağımsız olarak test edilmiş ve dört kategoriden birine atanmıştır:
- **`COMPATIBLE`:** Kural, profil altında hiçbir yoruma veya istisnaya gerek kalmadan %100 doğrudan geçerlidir.
- **`CONDITIONAL`:** Kural geçerlidir; ancak profilin gereksinimlerini karşılamak için açıkça tanımlanmış donanım kısıtlamalarına ve sınır koşullarına bağlıdır.
- **`CONFLICT`:** Profil ile kuralın lafzı veya mantığı arasında çözümsüz bir normatif çelişki vardır (Metodoloji veya Major-Version değişikliği gerektirir).
- **`UNRESOLVED`:** Donanım veya formal kanıt eksikliği nedeniyle geçerliliği henüz karara bağlanamamıştır.

| Invariant ID | Normatif Değişmez Tanımı | STRICT Profil Uyumluluğu | HYBRID Profil Uyumluluğu | Normatif Değerlendirme & Koşul Şartı |
| :--- | :--- | :---: | :---: | :--- |
| **M1** | **Trusted Sensor Acquisition:** Ham sensör verisi (ses/görüntü) ASLA Güvenli Alanı terk edemez. | **`COMPATIBLE`** | **`COMPATIBLE`** | **Tam Uyumlu:** HYBRID profilde de ham sensör verisi yalnızca NPU/SRAM alanında tutulur; dışarı aktarımı donanım katmanında imkansızdır. |
| **M2** | **Hardware-Enforced Domain Boundary:** Güvenli Alan ile Ağ/Kontrol Alanı arasındaki ayrım fiziksel olmalıdır (yazılımsal olamaz). | **`COMPATIBLE`** | **`COMPATIBLE`** | **Tam Uyumlu:** STRICT'te optokuplör/hava boşluğu; HYBRID'de ise Gate C'de doğrulanan OBI bridge ve SPI firewall donanım blokları fiziksel sınırı uygular. |
| **M3** | **One-Way Information Flow:** Korunan veriler kesinlikle tek yönlü akmalıdır. Doğrulanmış güncelleme/kontrol trafiği ters yönde girebilir. | **`COMPATIBLE`** | **`CONDITIONAL`** | **Koşullu Uyum:** M3'ün mevcut metni *"Doğrulanmış kontrol düzlemi ve firmware güncelleme trafiği Güvenli Alana girebilir"* istisnasını tanır. Ancak HYBRID'de giden telemetrinin *"Semantic Result"* sınıfında kalması ve ham veri rekonstrüksiyonuna izin vermemesi şarttır. (Bkz. Bölüm 2 analizi). |
| **M4** | **Reverse-Read Impossibility:** Ağ alanının Güvenli Alandan ham sensör ters-okuması (read-back) yapması donanımsal olarak imkansız olmalıdır. | **`COMPATIBLE`** | **`COMPATIBLE`** | **Tam Uyumlu:** OBI Subordinate Bridge (`zc_obi_subordinate_bridge.sv`) orphan drain ve `ST_TRAP` sentetik hata mekanizması ile ters-okuma yollarını donanımsal olarak bloke eder. |
| **M5** | **Control-Plane Isolation:** Güven sınırı veri yolunun yanı sıra reset, saat, güç, DMA ve debug hatlarını kapsamalıdır. | **`COMPATIBLE`** | **`COMPATIBLE`** | **Tam Uyumlu:** Property `F-OBI-07` sıcak reset kilitlemesini ispatlamıştır; AON OTP controller sıcak reset altında kilitli kalır (`F-OTP-05`). |
| **M6** | **Hardware-Rooted Execution Integrity:** Güvenli önyükleme ve güncelleme zinciri AI ağırlıklarını ve donanım envanterini kapsamalıdır. | **`COMPATIBLE`** | **`COMPATIBLE`** | **Tam Uyumlu:** AON OTP SVN (Security Version Number) yazma controller'ı anti-rollback mekanizmasını donanımsal olarak garanti eder (`F-OTP-01a/b`). |
| **M7** | **Raw-Data Lifetime Enforcement:** Ham verinin ömrü yalnızca yerel çıkarım (inference) döngüsüyle sınırlı olmalıdır. | **`COMPATIBLE`** | **`COMPATIBLE`** | **Tam Uyumlu:** HYBRID profilde telemetri üretilse dahi ham veri çıkarım bittiği anda M8'e devredilir. |
| **M8** | **Post-Inference Destruction/Zeroization:** Çıkarım biter bitmez tüm ham veri ve türetilmiş tensör kopyaları kalıcı olarak sıfırlanmalıdır. | **`COMPATIBLE`** | **`COMPATIBLE`** | **Tam Uyumlu:** Bellek sıfırlama (cryptographic zeroization / power-cut) her iki profilde de zorunludur. |
| **M9** | **Complete Sensor Inventory:** Cihazdaki tüm gizlilik-hassas sensörler istisnasız aynı güvenli alana bağlı olmalıdır. | **`COMPATIBLE`** | **`COMPATIBLE`** | **Tam Uyumlu:** İkincil ağ mikrofonu yasağı her iki profilde de tavizsiz geçerlidir. |
| **M10** | **Independent Conformance Evidence:** Uyumluluk iddiaları üretici beyanına değil, bağımsız ve ölçülebilir kanıtlara dayanmalıdır. | **`COMPATIBLE`** | **`CONDITIONAL`** | **Koşullu Uyum:** Gate C dijital formal kanıtları tamamlanmıştır (`PARTIAL / QUALIFIED`). Ancak HYBRID profilin fiziksel yan kanal ve covert channel güvencesi laboratuvar testine tabidir (**Gate D**). |

---

## 2. M3 ve Hibrit Bilgi Akışı Analizi: Major-Version Kararı

### Analiz:
M3 değişmezi lafzı itibarıyla şunu söyler:
> *"Protected raw-sensor information and derived representations SHALL flow strictly from the Trusted Domain to the Network Domain through a physically verifiable unidirectional channel. Authenticated control-plane and firmware-update traffic MAY enter the Trusted Domain, provided it cannot create a raw-sensor read-back path or a reverse raw-sensor information channel."*

- **STRICT Profil:** M3'ün orijinal tek yönlü donanım diyotu kuralıyla `%100 birebir` örtüşür.
- **HYBRID Profil:** Giden telemetri (sistem sağlığı, hata kodları, kümülatif durum) bir "Raw-Sensor Information" DEĞİLDİR; M3'ün izin verdiği bir "Semantic Command / State" türevidir.
- **Metodolojik Karar:** M1–M10 değişmezlerini değiştirmeye veya major-version kırmaya **gerek yoktur**.  
  Bunun yerine: **`zc-core-security-profiles.md`** belgesinde, M3'ün HYBRID profil altındaki yorumu *"Giden telemetri kesinlikle M3 sınırları dahilindedir; çünkü yalnızca doğrulanmış semantik sınıf 3 verileri içerir ve ham sensör verisi taşınamaz"* şeklinde normatif olarak bağlanmalıdır.

---

## 3. Donanım İzolasyon Sınırları: Gate C İspatları vs. Sistem Gerçekliği

Bağımsız denetçinin haklı uyarısı: *"RTL bloklarının doğrudan ağ işlemcisi izolasyonunu sağladığını iddia etmeyin."*

| İncelenen Blok | Gate C'de İspatlanan Gerçek Sınır | Henüz İspatlanmamış / Sistem Seviyesi Risk (Gate D) |
| :--- | :--- | :--- |
| **`zc_spi_flash_firewall`** | RDSR1 status reconciliation (`SR1[1:0]==00`), frame completion on rising /CS with SCK=0, secondary fault gating (`fault_high_sec_i`). | Harici SPI Flash çipinin analog gecikmesi, bus contention (aynı anda iki master'ın sürmesi), PCB iz empedansı. |
| **`zc_obi_subordinate_bridge`** | Tek çevrimlik yanıt teslimi, öksüz işlem emilimi (orphan drain), 1.024 çevrim watchdog timeout, ST_TRAP sentetik hata üretimi. | Çok master'lı SoC crossbar (Ibex + DMA + Ağ işlemcisi) arasındaki öncelik tahkisi ve PMP yetkilendirmesi (`BLOCKED`). |
| **`zc_aon_post_auth_ctrl`** | 4-fazlı DAI handshake, tek çevrimlik grant tüketimi, kalıcı fatal kilitlenme, Hsiao parity eşleşmesi. | Fiziksel antifuse programlama şarj pompası ($V_{\text{PP}} > 1.8\,\text{V}$), analog pulse süresi, dökümhane makro hücresi (`UNVERIFIED`). |

---

## 4. Dosya Bazlı Mevcut Belge Güncelleme Planı (Remediation Plan)

Bağımsız inceleme onayından sonra, mevcut 8 temel belge aşağıdaki plan doğrultusunda tek bir atomik commit ile güncellenecektir:

### 1. `README.md`
- **Mevcut Durum:** Yalnızca tek yönlü donanım diyotlarını ve hava boşluğunu anlatıyor.
- **Değişiklik:** "1.1 Güvenlik Profilleri: STRICT ve HYBRID" alt başlığı eklenecek. Gate C'de doğrulanan RTL bloklarına referans verilecek. `zc-core-security-profiles.md` ve `zc-core-hybrid-interconnect.md` linkleri konulacak.
- **Normatif Etki:** Informative / Giriş.

### 2. `zero-cloud-hardware-reference-architecture.md`
- **Mevcut Durum:** Yalnızca NPU->Opto->MCU şeması var.
- **Değişiklik:** Bölüm 2'ye "2.10: ZC-CORE Donanım Duvarı ve Güvenli Ara Bağlantı Mimarisi (SPI, OBI, AON OTP)" başlığı eklenecek. Şemaya (Mermaid) HYBRID veri yolu eklenecek; NPU ile Ağ İşlemcisi arasındaki donanım sınırları gösterilecek.
- **Normatif Etki:** Mimari Şartname güncellemesi.

### 3. `zero-cloud-core-scope-boundary.md`
- **Mevcut Durum:** Bölüm 1.20'de genel telemetri izni var, detay yok.
- **Değişiklik:** "İzin Verilen Hibrit Telemetri ve Bilgi Akışı Politikası" bölümü eklenecek. 5 veri sınıfı (Class 0..4) tanımlanacak; hız sınırlama ve sabit format kuralları yazılacak.
- **Normatif Etki:** Normatif Kapsam Sınırı.

### 4. `zero-cloud-core-attack-taxonomy.md`
- **Mevcut Durum:** AT-001..AT-010 tanımlı; hibrit tehditler eksik.
- **Değişiklik:** İki yeni saldırı sınıfı eklenecek:
  - `AT-011: Telemetry Steganographic Covert Channel (Yan kanal modülasyonu)`
  - `AT-012: Inbound Update Flash Desynchronization / Denial of Service`
- **Normatif Etki:** Tehdit Modeli Genişletmesi.

### 5. `zero-cloud-core-conformance-test-specification.md`
- **Mevcut Durum:** C1/C2/C3 laboratuvar seviyeleri var; STRICT/HYBRID profil testleri yok.
- **Değişiklik:** İki yeni test prosedürü taslağı eklenecek:
  - `FC-ZC-017: STRICT Profile Conformance Test (Zero Outbound Leakage)`
  - `FC-ZC-018: HYBRID Profile Telemetry & Firewall Test (OBI/SPI Boundary Check)`
- **Normatif Etki:** Test Şartnamesi Eklemesi (Gate D'de koşulacak).

### 6. `zero-cloud-core-implementation-coverage.md`
- **Mevcut Durum:** Yalnızca optik, FPGA ve ASIC diyot sınıfları var.
- **Değişiklik:** Tabloya "Hibrit Ara Bağlantı Donanım Sınıfı" eklenecek (OBI Bridge, SPI Flash Firewall, AON Controller).
- **Normatif Etki:** Uygulama Kapsamı Eşleşmesi.

### 7. `zero-cloud-core-conformance-evidence-matrix.md`
- **Mevcut Durum:** Yalnızca fiziksel lab testleri (FC-ZC) listeli.
- **Değişiklik:** Gate C dijital formal kanıtları (`CONSOLIDATED_NORMATIVE_EVIDENCE_MATRIX.md`) ile Gate D fiziksel kanıtları arasındaki hiyerarşik bağ kurulacak.
- **Normatif Etki:** Kanıt İzlenebilirliği.

### 8. `zero-cloud-core-defensive-publication.md`
- **Mevcut Durum:** Claim Families ZC-CORE-001..007 (Eski tek yönlü iddialar).
- **Değişiklik:** Yeni Claim Ailesi eklenecek:
  - **`ZC-CORE-008: Hardware-Enforced Bus Isolation & Secure Inbound Update Firewall`**  
    (3-katmanlı SPI Flash Firewall, OBI Subordinate Bridge ile öksüz işlem emilimi ve AON OTP 4-fazlı DAI handshake buluşları claim-style metin olarak yazılacak).
- **Çakışma Kontrolü:** ZC-CORE-001'den 007'ye kadar olan mevcut numaralandırma taranmış, `ZC-CORE-008` numarasının boşta ve çakışmasız olduğu doğrulanmıştır.
- **Normatif Etki:** Fikri Mülkiyet (Prior-Art) Savunma Genişlemesi.

---

## 5. Değişiklik Disiplini ve Yönetişim Kontrolü

1. Bu plandaki hiçbir değişiklik mevcut `zero-cloud-*.md` dosyalarına henüz uygulanmamıştır.
2. Tüm mimari şartnameler `docs/architecture/` altında taslak (`PROPOSED / NOT RELEASED / NOT SOC-VERIFIED`) olarak hazırlanmıştır.
3. Bağımsız denetçinin incelemesi ve onayı alındıktan sonra, yukarıdaki 8 dosya planlanan değişikliklerle senkronize edilecektir.
