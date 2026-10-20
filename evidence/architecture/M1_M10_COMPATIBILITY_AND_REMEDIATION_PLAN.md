# FREECULI ZC-CORE — M1–M10 Uyumluluk Matrisi ve Dosya Bazlı Değişiklik Planı
## (M1–M10 Invariant Compatibility Matrix & Documentation Remediation Plan)

**Belge Kimliği:** ZC-CORE-EVIDENCE-M1-M10-COMPAT-PLAN-01  
**Tarih:** 20 Ekim 2026  
**Revizyon:** 1.2.0 (Bağımsız Denetçi HAR-06..08 Bulguları Düzeltmesi)  
**Hedef Depo:** `FreeCuli/zero-cloud-hardware-architecture`  
**Çalışma Dalı:** `gate-c/formal-scope-audit`  
**Teknik Referans Tabanı:** Commit [`eb3ed5a`](https://github.com/FreeCuli/zero-cloud-hardware-architecture/commit/eb3ed5ad9fddb551506d43d2692bd040843af06f) (Run #45)  
**Yönetişim Statüsü:** **Gate C: PARTIAL / QUALIFIED** | **Gate D: UNVERIFIED** | **DO NOT MERGE** | **RELEASE BLOCKED**  

---

> [!WARNING]
> **YÖNETİŞİM VE KAPSAM BİLDİRİMİ (HAR-02, HAR-06, HAR-07 & HAR-08):**  
> Bu belge, ZC-CORE normatif değişmezlerinin (M1–M10) **STRICT** ve **HYBRID** çalışma profilleri karşısındaki uyumluluk durumunu ve depodaki normatif belgelerin güncellenme planını belirler.  
> Belgelerdeki teknik kapsam şişkinliğini önlemek ve denetçi bulgularını tam olarak kapatmak amacıyla:
> 1. **`DESIGN-COMPATIBLE`:** Mimari şartnamede tanımlanmış tasarım ilkesi ve hedefi.
> 2. **`IMPLEMENTATION-VERIFIED (PARTIAL)`:** Gate C kapsamında açık kaynak araçlarla ($t=20$) formal olarak ispatlanan bağımsız RTL blokları (`zc_spi_flash_firewall`, `zc_obi_subordinate_bridge`, `zc_aon_post_auth_ctrl`).
> 3. **`UNVERIFIED AT SOC/SILICON`:** Tüm SoC DMA izolasyonu, crossbar IOMMU, analog makro davranışları ve fiziksel yan kanal güvenceleri strictly **Gate D** kapsamındadır.
> 4. **HAR-06 Kanıt Ayrımı:** OBI 1.024 çevrimlik watchdog timeout davranışı `tb_zc_obi.sv` Test 2 ile dijital RTL simülasyonu seviyesinde doğrulanmıştır (`SIMULATED`). `F-OBI-04` ve `F-OBI-05` ise 1024 çevrimin tamamının tek bir temporal ispatı değil, yerel RTL adım endüksiyonu (step-induction) ve kilitlenme bayrağı assertion ispatlarıdır (`PROVEN` at local RTL step level).
> 5. **HAR-07 Telemetri Donanım Sınırı:** Mevcut Gate C RTL bloklarında telemetri veri sınıflandırıcısı, izin listesi denetleyicisi, paket kodlayıcı veya donanımsal hız sınırlayıcı BULUNMAMAKTADIR. Bu mekanizmalar mevcut RTL'de uygulanmış olmayıp, Gate D SoC entegrasyonu için önerilen sistem gereksinimidir (`PROPOSED / NOT IMPLEMENTED IN CURRENT RTL`).
> 6. **HAR-08 Sürümleme Kararı:** M3'ün normatif yorumu konusunda Seçenek A (v3.x Normatif Profil Eki) ve Seçenek B (v4.0.0 RFC) karşılaştırmalı karar matrisi sunulmuş; Class 3 telemetrinin tersine çevrilemezliği kanıtlanmış bir gerçek değil, bir tasarım hipotezi (`UNPROVEN DESIGN HYPOTHESIS`) olarak tanımlanmış ve nihai karar bağımsız standartlar incelemesine bırakılmıştır (`DECISION PENDING`).

---

## 1. M1–M10 Değişmezleri Uyumluluk Matrisi (STRICT vs. HYBRID)

Tüm ZC-CORE metodolojisinin temelini oluşturan M1–M10 kuralları, **STRICT** ve **HYBRID** profilleri karşısında bağımsız olarak değerlendirilmiş ve dört kategoriden birine atanmıştır:
- **`COMPATIBLE`:** Kural, profil altında hiçbir istisnaya veya ilave yoruma gerek kalmadan %100 doğrudan geçerlidir.
- **`CONDITIONAL`:** Kural geçerlidir; ancak açıkça tanımlanmış donanım kısıtlamalarına, sınır koşullarına veya harici güven varsayımlarına bağlıdır.
- **`CONFLICT`:** Profil ile kuralın lafzı arasında normatif bir çelişki vardır (Metodoloji veya Major-Version değişikliği gerektirir).
- **`UNRESOLVED`:** Donanım veya formal kanıt eksikliği nedeniyle geçerliliği henüz karara bağlanamamıştır.

### Konsolide Normatif Uyumluluk ve Kapsam Ayrıştırma Tablosu

| Invariant ID | Normatif Değişmez Tanımı | STRICT Profil | HYBRID Profil (Tasarım Hedefi) | Uygulanmış RTL & Formal Kapsam (Gate C: PARTIAL) | Eksik Sistem & Fiziksel Kapsam (Gate D: UNVERIFIED) |
| :--- | :--- | :---: | :---: | :--- | :--- |
| **M1** | **Trusted Sensor Acquisition:** Ham sensör verisi (ses/görüntü) ASLA Güvenli Alanı terk edemez. | **`COMPATIBLE`** | **`COMPATIBLE`** *(Design-Compatible)* | M1 bir alan topolojisi kuralıdır; Gate C dijital RTL blokları sensör arayüzü değil, veri yolu ve bellek köprüsüdür. | Fiziksel PCB hat ayrımı, sensör paket tamper koruması, analog iz empedansı. |
| **M2** | **Hardware-Enforced Domain Boundary:** Güvenli Alan ile Ağ Alanı ayrımı donanımsal olmalıdır (yazılımsal olamaz). | **`COMPATIBLE`** | **`CONDITIONAL`** *(Design-Compatible)* | `zc_obi_subordinate_bridge` (`F-OBI-01..07`) ve `zc_spi_flash_firewall` (`F-SPI-01..04`) ile veri yolu ve SPI katmanında donanımsal geçit kanıtlanmıştır. | Çok master'lı SoC crossbar DMA güvenlik duvarı, bellek yönetim birimi (IOMMU) ve PCB hava boşluğu analizi. |
| **M3** | **One-Way Information Flow:** Korunan veriler kesinlikle tek yönlü akmalıdır. Doğrulanmış kontrol trafiği ters yönde girebilir. | **`COMPATIBLE`** | **`CONDITIONAL`** *(Normatif Karara Bağlı - HAR-08)* | OBI bridge öksüz işlem emilimi (`F-OBI-06`) ve sentetik hata (`F-OBI-04/05` step) ile ters yönde kilitlenme engellenmiş; SPI firewall (`F-SPI-01/02`) ile yetkisiz yazma kısıtlanmıştır. **UYARI (HAR-07):** OBI bridge telemetri filtreleme, izin listesi veya hız sınırlaması YAPMAZ (`PROPOSED / NOT IMPLEMENTED IN CURRENT RTL`). | Class 3 telemetri için donanımsal allowlist filtresi ve hız sınırlayıcı IP (Gate D SoC entegrasyonu). CTS Annex B karşılıklı bilgi üst sınırı ($I(X;Y) < \text{MI}_{\text{upper\_bound}}$) laboratuvar testi. *(Bkz. Bölüm 2)*. |
| **M4** | **Reverse-Read Impossibility:** Ağ alanının Güvenli Alandan ham sensör ters-okuması (read-back) yapması donanımsal olarak imkansız olmalıdır. | **`COMPATIBLE`** | **`COMPATIBLE`** *(Design-Compatible / Implementation-Verified)* | `zc_obi_subordinate_bridge.sv` köprüsü, hedef çevre birimi arızasında veya kilitlenmesinde `ST_TRAP` sentetik hata verisi (`32'h0000_0000`) döndürerek okuma sızıntısını engeller (`F-OBI-04/05` step özellikleri `PROVEN`; 1024 çevrimlik sürekli kilitlenme `tb_zc_obi.sv` Test 2 ile `SIMULATED`). | Güvenli SRAM ve NPU kayıtlarının kötü niyetli bir SoC DMA master'ı tarafından doğrudan okunmasını engelleyen sistem düzeyinde crossbar koruması (`BLOCKED`). |
| **M5** | **Control-Plane Isolation:** Güven sınırı veri yolunun yanı sıra reset, saat, güç, DMA ve debug hatlarını kapsamalıdır. | **`COMPATIBLE`** | **`COMPATIBLE`** *(Design-Compatible / Implementation-Verified)* | OBI bridge sıcak reset (`rst_sys_ni`) altında host isteklerini sıfıra kilitler (`F-OBI-07`). AON OTP controller sıcak reset sırasında yetkilendirme kilidini korur (`F-OTP-05`). | Fiziksel saat/voltaj glitch enjeksiyonu laboratuvar testleri; asenkron reset kaldırılma/toparlanma (recovery/removal) Static Timing Analysis (STA). |
| **M6** | **Hardware-Rooted Execution Integrity:** Güvenli önyükleme ve güncelleme zinciri AI ağırlıklarını ve donanım envanterini kapsamalıdır. | **`COMPATIBLE`** | **`COMPATIBLE`** *(Design-Compatible / Implementation-Verified)* | `zc_aon_post_auth_ctrl.sv` 4-fazlı DAI el sıkışması (`F-OTP-02/03`), tek çevrimlik yetki tüketimi (`F-OTP-06`) ve SVN anti-rollback monotonluğunu (`F-OTP-01a/b`) donanımsal olarak garanti eder. | Harici Boot ROM kriptografik imza doğrulayıcısının doğruluğu (`rom_img_verif_valid_i` harici güven varsayımıdır); analog antifuse programlama şarj pompası ($V_{\text{PP}} > 1.8\,\text{V}$). |
| **M7** | **Raw-Data Lifetime Enforcement:** Ham verinin ömrü yalnızca yerel çıkarım (inference) döngüsüyle sınırlı olmalıdır. | **`COMPATIBLE`** | **`COMPATIBLE`** *(Design-Compatible)* | **`BLOCKED`**: Çift izli formel noninterference miter (`fv/zc_m7_m8_ni_sva.sv`), tam SoC ve NPU netlist'i bulunmadığı için Gate C'de yürütülememiştir. | Yaşam döngüsü donanım sayacı, çıkarım sonu donanımsal kesme tetikleyicisi ve SoC seviyesinde doğrulama. |
| **M8** | **Post-Inference Destruction/Zeroization:** Çıkarım biter bitmez tüm ham veri ve türetilmiş tensör kopyaları kalıcı olarak sıfırlanmalıdır. | **`COMPATIBLE`** | **`CONDITIONAL`** *(Fiziksel Kalıcılık Sınırı)* | **`BLOCKED`**: Dijital RTL düzeyinde SRAM sıfırlama mantığı tam SoC entegrasyonu beklemektedir. | Kriyojenik ve enerji kesintisi sonrası fiziksel hücre kalıcılık oranı ($R_{\text{rate}} \le 0.01\%$) testleri strictly Gate D laboratuvarına bırakılmıştır. |
| **M9** | **Complete Sensor Inventory:** Cihazdaki tüm gizlilik-hassas sensörler istisnasız aynı güvenli alana bağlı olmalıdır. | **`COMPATIBLE`** | **`COMPATIBLE`** *(Design-Compatible)* | M9 bir sistem mimarisi kuralıdır; ağ alanında ikincil mikrofon veya kamera bulunması doğrudan uygunsuzluktur. | Fiziksel kart (PCB) X-ray taraması, BOM bileşen denetimi ve optik mikroskopi. |
| **M10** | **Independent Conformance Evidence:** Uyumluluk iddiaları üretici beyanına değil, bağımsız ve ölçülebilir kanıtlara dayanmalıdır. | **`COMPATIBLE`** | **`CONDITIONAL`** *(HAR-05: Tüm Metin ve Tablolarda Tutarlı)* | Gate C kapsamındaki 3 dijital RTL bloğu açık kaynak formal araçlarla ($t=20$) ispatlanmıştır (`PARTIAL / QUALIFIED`). | HYBRID profilin fiziksel yan kanal, covert channel, glitch ve çip üzeri izolasyon güvenceleri Gate D akredite laboratuvar testlerine tabidir. |

---

## 2. M3 ve Hibrit Bilgi Akışı Analizi: Major-Version Karar Matrisi (HAR-08)

### 2.1 Normatif Uyuşmazlık (Normative Friction)
M3 değişmezi lafzı itibarıyla şunu şart koşar:
> *"Protected raw-sensor information and derived representations SHALL flow strictly from the Trusted Domain to the Network Domain through a physically verifiable unidirectional channel. Authenticated control-plane and firmware-update traffic MAY enter the Trusted Domain, provided it cannot create a raw-sensor read-back path or a reverse raw-sensor information channel."*

- **STRICT Profil:** M3'ün orijinal tek yönlü fiziksel donanım diyotu (optokuplör / hava boşluğu) şartıyla **%100 koşulsuz uyumludur**.
- **HYBRID Profil:** Giden yönde Class 3 telemetri (cihaz sağlık durumu, hata kodları, kümülatif çalışma saati) dışarı aktarılır. Aktarımın yapıldığı fiziksel arayüz (ör. OBI, Ethernet, Wi-Fi) çift yönlü bir veri yoludur.

### 2.2 Matematiksel Tersine Mühendislik / Geri Oluşturulamazlık Hipotezi (HAR-08 Uyarısı)
> [!IMPORTANT]
> **Matematiksel Geri Oluşturulamazlık Statüsü:**  
> Class 3 telemetrinin ham sensör verisini (Class 0) yeniden oluşturamayacağı (non-reconstructible) varsayımı, şu aşamada bir **KANITLANMAMIŞ TASARIM HİPOTEZİDİR (`UNPROVEN DESIGN HYPOTHESIS`)**.  
> Ayrık telemetri şemaları yapısal olarak ham ses/video örneklerinden bağımsız tasarlanmış olsa da, karşılıklı bilginin sıfır olduğu ($I(\text{Class 3}; \text{Class 0}) = 0$) henüz formal veya deneysel olarak ispatlanmamıştır. Bu iddia, Gate D kapsamındaki CTS Annex B laboratuvar testleri tamamlanmadan kesinleşmiş bir matematiksel kanıt olarak sunulamaz.

### 2.3 Kapsamlı Karar Etki Matrisi (Decision Impact Matrix)
Bağımsız denetçinin ve standartlar komitesinin değerlendirmesine sunulan iki normatif yol haritası aşağıda karşılaştırılmıştır:

| Değerlendirme Boyutu | Seçenek A: v3.x Normatif Profil Eki (Normative Profile Annex) | Seçenek B: v4.0.0 Kırıcı Mimari RFC (Breaking Architecture RFC) |
| :--- | :--- | :--- |
| **Normatif M3 Yorumu** | M3'ün korunan ham sensör verisi ve türetilmiş tensörleri (Class 0 ve 1) kapsadığı yorumlanır. İzinli Class 3 telemetri yetkilendirilmiş bir operasyonel istisna olarak kabul edilir. | M3'ün *"physically verifiable unidirectional channel"* lafzı katı yorumlanır; çift yönlü fiziksel aktarım kanalları veri sınıfına bakılmaksızın v3.x ile uyumsuz sayılır. |
| **Geri Oluşturulamazlık Hipotezi** | Tasarım hipotezinin katı ikili şema ve hız sınırlama altında korunduğu varsayılır. | Hipoteze dayanmak yerine, çift yönlü semantik sınırları açıkça tanımlayan yeni bir mimari sözleşme oluşturulur. |
| **Eski Cihazların Uygunluğu** | Mevcut STRICT cihazlar (v3.0–v3.3) geriye dönük tam uyumlu olarak `ZC-PROFILE-STRICT` altında tescilli kalır. | Mimari çatallanma (bifurcation) oluşur: v3.x dalı yalnızca STRICT, v4.x dalı ise HYBRID + STRICT olarak ikiye ayrılır. |
| **CTS Test Paketi Etkisi** | CTS temel paketi bozulmaz; HYBRID uyumluluğu seçimli bir ek olarak (CTS Annex B) test paketine eklenir. | CTS baştan aşağı modüler profil paketlerine bölünür (`CTS-Core`, `CTS-Strict`, `CTS-Hybrid`). |
| **Fikrî Mülkiyet (Prior-Art) Etkisi**| Mevcut ZC-CORE-001..007 patent savunma iddiaları korunur; `ZC-CORE-008` bir alt iddia ailesi olarak v3.x'e eklenir. | v4.0.0 için sıfırdan bağımsız bir patent savunma tabanı oluşturulur; çok master'lı veri yolu yangın duvarı bağımsız tescil edilir. |
| **Sürümleme ve Yayın Takvimi** | v3.4.0 sürümü ile daha hızlı Zenodo yayını yapılabilir; ancak lafzi tek yönlülük kuralı normatif tartışma riski taşır. | Gate D SoC silikon üretimi ve laboratuvar karşılıklı bilgi ölçümü beklenir; azami normatif netlik sağlanır, yayın gecikir. |
| **Yönetişim Kararı** | **`DECISION PENDING INDEPENDENT STANDARDS REVIEW`** | **`DECISION PENDING INDEPENDENT STANDARDS REVIEW`** |

---

## 3. Donanım İzolasyon Sınırları: Gate C İspatları vs. Sistem Gerçekliği (HAR-02, HAR-06 & HAR-07)

RTL bloklarının yeteneklerinin sistem düzeyinde genel bir DMA güvenlik duvarı, bellek denetleyicisi veya telemetri filtresi gibi yansıtılmasını engellemek için, aşağıdaki teknik sınırlar açıkça kayıt altına alınmıştır:

| İncelenen RTL Blok | Gate C'de İspatlanan Gerçek Sınırlar (Formal Proof Scope & Simulation) | Harici Güven Varsayımları (Trust Assumptions) | İspatlanmamış Sistem, Telemetri & Fiziksel Riskler (Gate D Deliverables) |
| :--- | :--- | :--- | :--- |
| **`zc_spi_flash_firewall`** | - RDSR1 durum mutabakatı (`SR1[1:0] == 00`).<br>- SCK=0 iken yükselen /CS ile çerçeve tamamlama (`F-SPI-02`).<br>- İkincil hata durumunda donanımsal /CS deselect (`cs_n_flash_eff_o`).<br>- Bank B commit yetkilendirme kapısı (`bank_b_commit_ready_o`). | **HAR-04:** Kriptografik imza doğrulaması RTL içinde DEĞİLDİR. `rom_img_verif_valid_i` sinyalinin güvenilir bir Boot ROM motorundan geldiği harici bir güven varsayımıdır.<br>`bank_b_commit_ready_o = spi_idle_ready_o && rom_img_verif_valid_i`. | - Harici SPI Flash yongasının analog gecikmeleri.<br>- Eşzamanlı master çakışmaları (bus contention).<br>- PCB iletim hattı empedans bozulmaları ve glitch enjeksiyonu. |
| **`zc_obi_subordinate_bridge`** | - Tek çevrimlik istek teslimi (`F-OBI-01`).<br>- Öksüz yanıt emilimi (orphan drain) (`F-OBI-06`).<br>- Sıcak reset (`rst_sys_ni`) altında istek blokajı (`F-OBI-07`).<br>- `ST_TRAP` sentetik hata verisi üretimi.<br>- **HAR-06 Kanıt Sınıflandırması:** 1.024 çevrimlik kesintisiz watchdog timeout davranışı `tb_zc_obi.sv` Test 2 ile dijital RTL simülasyonu seviyesinde doğrulanmıştır (`SIMULATED`). `F-OBI-04` ve `F-OBI-05` ise 1024 çevrimin tamamının tek bir temporal ispatı değil, yerel RTL adım endüksiyonu (step-induction) ve kilitlenme bayrağı assertion ispatlarıdır (`PROVEN` at local RTL step level). | Gelen OBI ana isteklerinin geçerli bir CPU/DMA master'ından üretildiği varsayılır. | - **HAR-07 Donanım Sınırı:** Bu blok telemetri filtreleme, izin listesi denetimi veya hız sınırlaması YAPMAZ (`PROPOSED / NOT IMPLEMENTED IN CURRENT RTL`). OBI köprüsü yalnızca bus protokolü seviyesinde ayrıştırma sağlar.<br>- **HAR-02 Donanım Sınırı:** Bu blok bir SoC DMA güvenlik duvarı veya MPU DEĞİLDİR. Çok master'lı crossbar üzerindeki bellek erişim yetkilendirmesi açık bir sistem riskidir (`BLOCKED`). |
| **`zc_aon_post_auth_ctrl`** | - 4-fazlı DAI el sıkışma protokolü (`F-OTP-02/03`).<br>- Tek çevrimlik yetki tüketimi (`F-OTP-06`).<br>- Sıcak resette silinmeyen kalıcı fatal kilitlenme (`F-OTP-05`).<br>- Hsiao (22,16) kod sözcüğü parite denetimi (`F-OTP-04`).<br>- SVN anti-rollback monotonluğu (`F-OTP-01a/b`). | DAI arayüzünün fiziksel OTP analog makrosuna doğrudan bağlı olduğu ve harici hata sinyallerinin (`volt_supervisor_fault_i`, `tamper_alert_i`) doğru çalıştığı varsayılır. | - Fiziksel antifuse programlama şarj pompası ($V_{\text{PP}} > 1.8\,\text{V}$) analog darbe süresi.<br>- Dökümhane (foundry) OTP makro hücresi güvenilirliği ve veri saklama (retention) fiziği. |

---

## 4. Dosya Bazlı Mevcut Belge Güncelleme Planı (Remediation Plan)

Bağımsız denetçinin nihai onayından sonra, mevcut 8 temel normatif belge aşağıdaki plan doğrultusunda tek bir atomik commit ile güncellenecektir:

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
- **Değişiklik:** "İzin Verilen Hibrit Telemetri ve Bilgi Akışı Politikası" bölümü eklenecek. 5 veri sınıfı (Class 0..4) tanımlanacak; hız sınırlama, epoch tabanlı gönderim ve sabit ikili format kuralları yazılacak.
- **Normatif Etki:** Normatif Kapsam Sınırı.

### 4. `zero-cloud-core-attack-taxonomy.md`
- **Mevcut Durum:** AT-001..AT-010 tanımlı; hibrit tehditler eksik.
- **Değişiklik:** İki yeni saldırı sınıfı eklenecek:
  - `AT-011: Telemetry Steganographic Covert Channel (Yan kanal modülasyonu ve bilgi sızdırma)`
  - `AT-012: Inbound Update Flash Desynchronization / Denial of Service (SPI çerçeve bozma)`
- **Normatif Etki:** Tehdit Modeli Genişletmesi.

### 5. `zero-cloud-core-conformance-test-specification.md`
- **Mevcut Durum:** C1/C2/C3 laboratuvar seviyeleri var; STRICT/HYBRID profil testleri yok.
- **Değişiklik:** İki yeni test prosedürü taslağı eklenecek:
  - `FC-ZC-017: STRICT Profile Conformance Test (Zero Outbound Leakage via Anechoic RF Audit)`
  - `FC-ZC-018: HYBRID Profile Telemetry & Firewall Test (OBI/SPI Boundary Check & Mutual Information Bound)`
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
    (3-katmanlı SPI Flash Firewall, OBI Subordinate Bridge ile öksüz işlem emilimi ve AON OTP 4-fazlı DAI handshake buluşları claim-style patent savunma diliyle yazılacak).
- **Çakışma Kontrolü:** ZC-CORE-001'den 007'ye kadar olan mevcut numaralandırma taranmış, `ZC-CORE-008` numarasının boşta ve çakışmasız olduğu doğrulanmıştır.
- **Normatif Etki:** Fikri Mülkiyet (Prior-Art) Savunma Genişlemesi.

---

## 5. Değişiklik Disiplini ve Yönetişim Kontrolü

1. Bu plandaki hiçbir değişiklik mevcut 14 temel normatif belgeye (`zero-cloud-*.md`, `README.md`, `ZERO-CLOUD-RELEASE-MANIFEST.md`) henüz uygulanmamıştır.
2. Tüm mimari şartnameler `docs/architecture/` altında taslak (`PROPOSED / NOT RELEASED / NOT SOC-VERIFIED`) olarak tutulmaktadır.
3. Çalışma strictly `gate-c/formal-scope-audit` dalında yürütülmektedir; ana dal (`main`) korunmaktadır.
4. Bağımsız denetçinin bu düzeltmeler üzerindeki resmi onayı alınmadan ve HAR-08 kararı netleşmeden ana normatif dokümanlarda hiçbir satır değiştirilmeyecektir.
