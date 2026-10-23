# FREECULI ZC-CORE — M1–M10 Uyumluluk Matrisi ve Dosya Bazlı Değişiklik Planı
## (M1–M10 Invariant Compatibility Matrix & Documentation Remediation Plan)

**Belge Kimliği:** ZC-CORE-EVIDENCE-M1-M10-COMPAT-PLAN-01
**Tarih:** 20 Ekim 2026
**Revizyon:** 1.4.0 (Bağımsız Denetçi HAR-11..13 Bulguları Düzeltmesi)
**Hedef Depo:** `FreeCuli/zero-cloud-hardware-architecture`
**Çalışma Dalı:** `gate-c/formal-scope-audit`
**Teknik Referans Tabanı:** Commit [`eb3ed5a`](https://github.com/FreeCuli/zero-cloud-hardware-architecture/commit/eb3ed5ad9fddb551506d43d2692bd040843af06f) (Run #45)
**Yönetişim Statüsü (Gate C Kapanışında):** **Gate C: PARTIAL / QUALIFIED** | **Gate D: UNVERIFIED** | **DO NOT MERGE** | **RELEASE BLOCKED (Tarihsel Planlama Kaydı)**

> [!NOTE]
> **Tarihsel Planlama Kaydı:** Bu belge, RC1'den RC2'ye geçiş öncesinde hazırlanmış ilk planlama analizidir. İçindeki "DO NOT MERGE / RELEASE BLOCKED" ifadeleri o tarihteki kapı durumunu yansıtır; güncel v4.0.0-rc2 aday sürüm sürecini kısıtlamaz.

---

> [!WARNING]
> **YÖNETİŞİM VE KAPSAM BİLDİRİMİ (HAR-02, HAR-06..HAR-13):**
> Bu belge, ZC-CORE normatif değişmezlerinin (M1–M10) **STRICT** ve **HYBRID** çalışma profilleri karşısındaki uyumluluk durumunu ve depodaki normatif belgelerin güncellenme planını belirler.
> Belgelerdeki teknik kapsam şişkinliğini önlemek ve denetçi bulgularını tam olarak kapatmak amacıyla:
> 1. **`DESIGN-COMPATIBLE`:** Mimari şartnamede tanımlanmış tasarım ilkesi ve hedefi.
> 2. **`IMPLEMENTATION-VERIFIED (PARTIAL)`:** Gate C kapsamında açık kaynak araçlarla ($t=20$) formal olarak ispatlanan bağımsız RTL blokları (`zc_spi_flash_firewall`, `zc_obi_subordinate_bridge`, `zc_aon_post_auth_ctrl`).
> 3. **`UNVERIFIED AT SOC/SILICON`:** Tüm SoC DMA izolasyonu, crossbar IOMMU, analog makro davranışları ve fiziksel yan kanal güvenceleri strictly **Gate D** kapsamındadır.
> 4. **HAR-06 Kanıt Ayrımı:** OBI 1.024 çevrimlik watchdog timeout davranışı `tb_zc_obi.sv` Test 2 ile dijital RTL simülasyonu seviyesinde doğrulanmıştır (`SIMULATED`). `F-OBI-04` ve `F-OBI-05` ise 1024 çevrimin tamamının tek bir temporal ispatı değil, yerel RTL adım endüksiyonu (step-induction) ve kilitlenme bayrağı assertion ispatlarıdır (`PROVEN` at local RTL step level).
> 5. **HAR-07 & HAR-11 Uygulama Ayrımı:** Mevcut Gate C RTL bloklarında telemetri veri sınıflandırıcısı, izin listesi denetleyicisi, paket kodlayıcı veya donanımsal hız sınırlayıcı BULUNMAMAKTADIR. `M3-RFC-REVISED` içerisindeki gereksinimler geleceğe yönelik zorunlu mimari şartlardır (`SHALL`); mevcut RTL'de uygulanmış olmayıp, Gate D SoC entegrasyonu için önerilen sistem gereksinimidir (`PROPOSED / NOT IMPLEMENTED IN CURRENT RTL`). Ayrıca Gate C yerel formal ispatları, uçtan uca HYBRID bilgi akışı noninterference kanıtı değildir.
> 6. **HAR-12 Savunma Amaçlı Yayın ve Fikrî Mülkiyet Sınırları:** Zenodo teknik raporu, kamuya açıklanan teknik içeriği ve erişilebilirlik tarihini belgeleme (timestamped documentary prior art) amacını taşır. Otomatik bir patent hakkı, patent başvuru önceliği veya dünya çapında mutlak patent engeli garantisi SAĞLAMAZ. Yayın öncesi patent vekili / IP hukuk danışmanı incelemesi zorunludur.
> 7. **HAR-13 Karşılıklı Bilgi Araştırma Hedefi:** Covert-channel istatistiksel karşılıklı bilgi denklemi ($\epsilon_{\text{target}}$) onaylanmış bir sertifikasyon eşiği değil, **`UNVERIFIED RESEARCH / VALIDATION TARGET`** niteliğindedir; tüm olası fiziksel sızıntı yollarının yokluğunu matematiksel olarak kanıtlamaz.

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
| **M3** | **One-Way Information Flow:** Korunan veriler kesinlikle tek yönlü akmalıdır. Doğrulanmış kontrol trafiği ters yönde girebilir. | **`COMPATIBLE`** | **`CONDITIONAL`** *(Normatif Karara Bağlı - HAR-08/09/11)* | OBI bridge öksüz işlem emilimi (`F-OBI-06`) ve sentetik hata (`F-OBI-04/05` step) ile ters yönde kilitlenme engellenmiş; SPI firewall (`F-SPI-01/02`) ile yetkisiz yazma kısıtlanmıştır. **UYARI (HAR-07/11):** OBI bridge telemetri filtreleme, izin listesi veya hız sınırlaması YAPMAZ (`PROPOSED / NOT IMPLEMENTED IN CURRENT RTL`). Yerel formal ispatlar uçtan uca bilgi akışı noninterference kanıtı değildir. | Class 3 telemetri için donanımsal allowlist filtresi ve hız sınırlayıcı IP (Gate D SoC entegrasyonu). CTS Annex B istatistiksel karşılıklı bilgi üst sınırı ($I(S_{\text{raw}}; T_{\text{out}}) \le \epsilon_{\text{target}}$) araştırma testi. *(Bkz. Bölüm 2)*. |
| **M4** | **Reverse-Read Impossibility:** Ağ alanının Güvenli Alandan ham sensör ters-okuması (read-back) yapması donanımsal olarak imkansız olmalıdır. | **`COMPATIBLE`** | **`COMPATIBLE`** *(Design-Compatible / Implementation-Verified)* | `zc_obi_subordinate_bridge.sv` köprüsü, hedef çevre birimi arızasında veya kilitlenmesinde `ST_TRAP` sentetik hata verisi (`32'h0000_0000`) döndürerek okuma sızıntısını engeller (`F-OBI-04/05` step özellikleri `PROVEN`; 1024 çevrimlik sürekli kilitlenme `tb_zc_obi.sv` Test 2 ile `SIMULATED`). | Güvenli SRAM ve NPU kayıtlarının kötü niyetli bir SoC DMA master'ı tarafından doğrudan okunmasını engelleyen sistem düzeyinde crossbar koruması (`BLOCKED`). |
| **M5** | **Control-Plane Isolation:** Güven sınırı veri yolunun yanı sıra reset, saat, güç, DMA ve debug hatlarını kapsamalıdır. | **`COMPATIBLE`** | **`COMPATIBLE`** *(Design-Compatible / Implementation-Verified)* | OBI bridge sıcak reset (`rst_sys_ni`) altında host isteklerini sıfıra kilitler (`F-OBI-07`). AON OTP controller sıcak reset sırasında yetkilendirme kilidini korur (`F-OTP-05`). | Fiziksel saat/voltaj glitch enjeksiyonu laboratuvar testleri; asenkron reset kaldırılma/toparlanma (recovery/removal) Static Timing Analysis (STA). |
| **M6** | **Hardware-Rooted Execution Integrity:** Güvenli önyükleme ve güncelleme zinciri AI ağırlıklarını ve donanım envanterini kapsamalıdır. | **`COMPATIBLE`** | **`COMPATIBLE`** *(Design-Compatible / Implementation-Verified)* | `zc_aon_post_auth_ctrl.sv` 4-fazlı DAI el sıkışması (`F-OTP-02/03`), tek çevrimlik yetki tüketimi (`F-OTP-06`) ve SVN anti-rollback monotonluğunu (`F-OTP-01a/b`) donanımsal olarak garanti eder. | Harici Boot ROM kriptografik imza doğrulayıcısının doğruluğu (`rom_img_verif_valid_i` harici güven varsayımıdır); analog antifuse programlama şarj pompası ($V_{\text{PP}} > 1.8\,\text{V}$). |
| **M7** | **Raw-Data Lifetime Enforcement:** Ham verinin ömrü yalnızca yerel çıkarım (inference) döngüsüyle sınırlı olmalıdır. | **`COMPATIBLE`** | **`COMPATIBLE`** *(Design-Compatible)* | **`BLOCKED`**: Çift izli formel noninterference miter (`fv/zc_m7_m8_ni_sva.sv`), tam SoC ve NPU netlist'i bulunmadığı için Gate C'de yürütülememiştir. | Yaşam döngüsü donanım sayacı, çıkarım sonu donanımsal kesme tetikleyicisi ve SoC seviyesinde doğrulama. |
| **M8** | **Post-Inference Destruction/Zeroization:** Çıkarım biter bitmez tüm ham veri ve türetilmiş tensör kopyaları kalıcı olarak sıfırlanmalıdır. | **`COMPATIBLE`** | **`CONDITIONAL`** *(Fiziksel Kalıcılık Sınırı)* | **`BLOCKED`**: Dijital RTL düzeyinde SRAM sıfırlama mantığı tam SoC entegrasyonu beklemektedir. | Kriyojenik ve enerji kesintisi sonrası fiziksel hücre kalıcılık oranı ($R_{\text{rate}} \le 0.01\%$) testleri strictly Gate D laboratuvarına bırakılmıştır. |
| **M9** | **Complete Sensor Inventory:** Cihazdaki tüm gizlilik-hassas sensörler istisnasız aynı gizli alana bağlı olmalıdır. | **`COMPATIBLE`** | **`COMPATIBLE`** *(Design-Compatible)* | M9 bir sistem mimarisi kuralıdır; ağ alanında ikincil mikrofon veya kamera bulunması doğrudan uygunsuzluktur. | Fiziksel kart (PCB) X-ray taraması, BOM bileşen denetimi ve optik mikroskopi. |
| **M10** | **Independent Conformance Evidence:** Uyumluluk iddiaları üretici beyanına değil, bağımsız ve ölçülebilir kanıtlara dayanmalıdır. | **`COMPATIBLE`** | **`CONDITIONAL`** *(HAR-05: Tüm Metin ve Tablolarda Tutarlı)* | Gate C kapsamındaki 3 dijital RTL bloğu açık kaynak formal araçlarla ($t=20$) ispatlanmıştır (`PARTIAL / QUALIFIED`). | HYBRID profilin fiziksel yan kanal, covert channel, glitch ve çip üzeri izolasyon güvenceleri Gate D akredite laboratuvar testlerine tabidir. |

---

## 2. M1/M3 Normatif Çelişki Analizi ve Sürümleme Karar Matrisi (HAR-09..HAR-13)

### 2.1 Orijinal Metinlerin Birebir Karşılaştırması ve Normatif Sürtüşme (HAR-09)
Mevcut [`zero-cloud-core-methodology-invariants.md`](../../zero-cloud-core-methodology-invariants.md) belgesindeki ilgili maddeler birebir incelendiğinde:

1. **M1 (Trusted Sensor Acquisition):**
   > *"Raw sensor data (audio/video) SHALL NEVER leave the Trusted Domain."*
2. **M3 (One-Way Information Flow):**
   > *"Protected raw-sensor information and derived representations SHALL flow strictly from the Trusted Domain to the Network Domain through a physically verifiable unidirectional channel. Authenticated control-plane and firmware-update traffic MAY enter the Trusted Domain, provided it cannot create a raw-sensor read-back path or a reverse raw-sensor information channel."*
3. **M4 (Reverse-Read Impossibility):**
   > *"It MUST be physically or logically impossible for the Network/Control Domain to execute a functional reverse read (raw sensor read-back) from the Trusted Domain over a physical reverse channel..."*
4. **M8 (Post-Inference Destruction/Invalidation):**
   > *"Once inference completes, all persistent and temporary copies of raw data SHALL become irreversibly unrecoverable (e.g., physically destroyed or cryptographically zeroized across all caching layers)."*
5. **Composition Rule:**
   > *"Sensor Acquisition → Trusted Local Inference → Controlled Semantic Release → Absolute Raw-Data Destruction → Network/Actuator Operation."*

#### Normatif Çelişki / Yazım Hatası Analizi:
- **Çelişki:** M1 açıkça ham sensör verisinin Güvenli Alanı ASLA terk edemeyeceğini (`SHALL NEVER leave`) ve M8 çıkarım biter bitmez tüm kopyalarının geri döndürülemez biçimde yok edileceğini emrederken; eski M3 metni lafzı itibarıyla *"Protected raw-sensor information and derived representations SHALL flow strictly from the Trusted Domain to the Network Domain..."* diyerek korunan ham verinin Ağ Alanına akacağını söylemektedir!
- **Asıl Amaç (Composition Rule):** Belgenin kendi içindeki Composition Rule ise gerçek mimari akışı netleştirir: Dışarıya yalnızca **"Controlled Semantic Release"** (Class 2 komutlar, Class 3 telemetri) akar; ham veri ise **"Absolute Raw-Data Destruction"** aşamasında silinir.
- **Sonuç:** Bu durum, eski ZC-CORE metinlerinde var olan tarihsel bir yazım ve ifade hatasıdır (conflated drafting). HYBRID profilini bu çelişki yokmuş gibi eski metnin üzerine inşa etmek hukuki ve teknik açıdan sakıncalıdır. Bu çelişkiyi çözmek için düzeltilmiş bir normatif sözleşme zorunludur.

---

### 2.2 Önerilen Düzeltilmiş M3 Sözleşmesi (`M3-RFC-REVISED`)
Mevcut v3.x değişmezler belgesine dokunulmaksızın, v4.0.0 RFC taslağı için hazırlanan düzeltilmiş normatif sözleşme şöyledir:

> #### Düzeltilmiş M3 Değişmezi: `M3-RFC-REVISED`
> 1. **Korunan Sensör Verisinin Dışarı Çıkış Yasağı:**
>    Ham sensör verisi (Class 0) ve türetilmiş tensör/embedding gösterimleri (Class 1), M1 ve M8 ilkeleri uyarınca Güven Sınırını KESİNLİKLE terk edemez.
> 2. **Tek Yönlü Semantik Çıkış İzni:**
>    Yalnızca yerel çıkarım sonucu üretilen doğrulanmış ayrık fiziksel çalıştırma komutları (Class 2) ve donanımsal olarak hız sınırlı, sabit şemalı sistem telemetrisi (Class 3) donanımsal bir geçit üzerinden dışarı akabilir.
> 3. **Donanım Denetimli Ters Giriş (Inbound):**
>    Doğrulanmış kontrol düzlemi ve firmware güncelleme trafiği, donanımsal güvenlik duvarları (SPI dual /CS ve Boot ROM imza doğrulaması) üzerinden Güvenli Alana girebilir; ancak hiçbir koşulda ters-okuma (M4) veya ham veri sızdırma yolu oluşturamaz.
> 4. **Fiziksel Enforcement Ayrımı:**
>    - **STRICT Profil:** Çıkış kesinlikle tek yönlü fiziksel bir donanım diyotu (optokuplör / hava boşluğu) ile sağlanır.
>    - **HYBRID Profil:** Çift yönlü fiziksel veri yolları (OBI / SPI) ancak formal olarak doğrulanmış veri yolu güvenlik duvarları (orphan drain, synthetic error trap) ve bağımsız donanımsal hız sınırlayıcılar aracılığıyla sınırlandırıldığında kabul edilir.

> [!IMPORTANT]
> **Uygulama Boşluğu Bildirimi (HAR-11 Çözümü):**
> `M3-RFC-REVISED` içerisindeki kurallar, ZC-CORE v4.0.0 HYBRID profili için **gelecekteki zorunlu mimari şartlardır (`SHALL` gereksinimi)**.
> Mevcut dijital RTL tabanında (`eb3ed5a` / Gate C):
> 1. Uygulanan RTL modülleri (`zc_obi_subordinate_bridge`, `zc_spi_flash_firewall`, `zc_aon_post_auth_ctrl`) yalnızca veri yolu seviyesinde protokol ayrıştırması, öksüz yanıt emilimi ve flash yetkilendirme geçidi sağlar; telemetri izin listesi denetimi, yük doğrulaması, donanımsal hız sınırlaması veya tüm SoC DMA yangın duvarı içermez. Bu eksik mekanizmalar strictly **`PROPOSED / NOT IMPLEMENTED OR UNVERIFIED`** durumundadır (Gate D SoC entegrasyonuna ertelenmiştir).
> 2. Gate C'deki yerel formal ispatlar (`F-SPI-01..04`, `F-OBI-01..07`, `F-OTP-01..06`) blok düzeyinde protokol kurallarını doğrular; tüm hibrit sistem genelinde uçtan uca bilgi akışı noninterference kanıtı DEĞİLDİR (`fv/zc_m7_m8_ni_sva.sv` altında `BLOCKED` durumdadır).

---

### 2.3 Bağımsız Dört Kilometre Taşının Ayrıştırılması (HAR-10 & HAR-12)
Gereksiz takvim kilitlenmelerini önlemek ve hukuki/fikrî mülkiyet sınırlarını tam olarak belirlemek amacıyla, süreç 4 bağımsız kilometre taşına bölünmüştür:

1. **Kilometre Taşı 1: Mimari Şartname ve RFC Yönetişimi (`GOVERNANCE-RFC`)**
   - STRICT ve HYBRID profillerinin, tehdit modelinin (`AT-011`, `AT-012`), ara bağlantı sözleşmelerinin ve `M3-RFC-REVISED` metninin dokümantasyon düzeyinde tamamlanması.
   - *Durum:* Taslak dokümanlar seviyesinde hazırdır. Donanım üretim bağımlılığı yoktur.
2. **Kilometre Taşı 2: Savunma Amaçlı Teknik Yayın ve Fikrî Mülkiyet (Zenodo DOI / Prior-Art - HAR-12)**
   - ZC-CORE metodolojisi, düzeltilmiş M3 sözleşmesi ve `ZC-CORE-008` (Donanım Veri Yolu Güvenlik Duvarı ve İçe Güncelleme Mimarisi) buluşlarının DOI ile zaman damgalı tescili.
   - *Belgeleme Niteliği:* Kamuya açıklanan teknik içeriğin ve kamuya erişilebilirlik tarihinin doğrulanabilir kanıtını oluşturur (35 U.S.C. § 102, EPC Madde 54 kapsamında dokümante edilmiş prior-art).
   - *Hukuki ve Fikrî Mülkiyet Sınırları:* **Otomatik bir patent koruması sağlamaz, patent başvuru önceliği oluşturmaz ve tüm dünya yargı alanlarında mutlak bir patent engeli garantisi vermez.** FreeCuli açık donanım B2B çift lisanslama (CERN-OHL-S) modelini benimsemiştir ve TÜBİTAK dahil herhangi bir patent başvurusu taahhüdü bulunmadığını teyit etmiştir. Strateji patent başvurusu yapmak değil, savunma amaçlı prior-art oluşturmaktır. Patent vekili / IP hukuk danışmanı incelemesi, patent başvurusu tartışmak için değil; teknik açıklamanın (enablement) savunma gücünü ve uluslararası geçerliliğini teyit etmek içindir.
   - *Sınır:* **Fiziksel silikon teyp-out gerektirmez.** Tasarım hedefleri dürüstçe mimari şartname olarak beyan edilir; silikon garantisi gibi sunulmaz.
3. **Kilometre Taşı 3: Dijital FPGA ve Tam SoC Doğrulaması (`FPGA-SOC-GATE-C`)**
   - Gate C açık kaynak formal ispatları (`PROVEN`: `F-SPI-01..04`, `F-OBI-01..07`, `F-OTP-01..06`).
   - RTL dijital simülasyonları (`SIMULATED`: 1.024 çevrimlik OBI watchdog).
   - FPGA üzerinde çift çekirdekli Ibex CPU + NPU + DMA içeren tam SoC netlist doğrulaması.
4. **Kilometre Taşı 4: Fiziksel Silikon Uygunluğu ve Ticari Sürüm (Gate D)**
   - Dökümhane (foundry) antifuse analog makro karakterizasyonu ($V_{\text{PP}} > 1.8\,\text{V}$).
   - Kriyojenik / enerji kesintisi SRAM kalıcılık analizi ($R_{\text{rate}} \le 0.01\%$).
   - Akredite ISO 17025 laboratuvarında RF yankısız oda EM yan kanal ve istatistiksel karşılıklı bilgi sızıntı araştırma testi:
     $$\max_{\mathcal{A} \in \mathcal{M}_{\text{threat}}} I(S_{\text{raw}}; T_{\text{out}} \mid \mathcal{O}_{\text{side-channel}}) \le \epsilon_{\text{target}}$$
   - Ticari sürüm ve nihai onay (DO NOT MERGE kısıtlamasının kaldırılması).

---

### 2.4 Kapsamlı Sürümleme Karar Matrisi ve Stratejik Tavsiye

| Değerlendirme Boyutu | Seçenek A: v3.x Normatif Profil Eki (Annex) | Seçenek B: v4.0.0 Kırıcı Mimari RFC (Breaking RFC) |
| :--- | :--- | :--- |
| **Normatif M3 Çözümü** | Eski M1/M3 metin sürtüşmesini yorum yoluyla aşmaya çalışır; lafzi çelişki tortusu kalır. | `M3-RFC-REVISED` sözleşmesini doğrudan yürürlüğe koyar; M1/M3 çelişkisini kökten temizler. |
| **Zenodo Savunma Yayını (KM 2)** | v3.3.x ek yayını olarak yapılır; patent denetçilerinde eski tek yönlü v3.0 patentleriyle terminolojik çelişki riski doğurur. | **Dokümante Edilmiş Prior-Art Açıklaması:** v4.0.0 RFC olarak yayımlanır; `ZC-CORE-008` için v3.0 kayıtlarını bulandırmadan bağımsız bir prior-art açıklaması oluşturur. Silikon üretimi beklemez. |
| **Eski Cihazların Durumu** | Tüm v3.x cihazları aynı şemsiye altında tutar. | v3.3.0-rc2'yi katı ve değişmez STRICT standardı olarak dondurur; HYBRID'i v4.0.0 hattında temiz biçimde konumlandırır. |
| **CTS Test Paketi** | CTS v3 paketine yama yapılır. | Modüler CTS paketleri kurulur (`CTS-Core`, `CTS-Strict`, `CTS-Hybrid`). |
| **Stratejik Tavsiye (Denetçi Görüşü)** | Uygulanabilir; ancak lafzi tartışmalara açıktır. | **TAVSİYE EDİLEN:** En düşük hukuki ve fikrî mülkiyet riski taşıyan, en temiz mimari yoldur. |
| **Yönetişim Kararı** | **`DECISION PENDING INDEPENDENT STANDARDS REVIEW`** | **`DECISION PENDING INDEPENDENT STANDARDS REVIEW`** |

---

### 2.5 Covert-Channel Karşılıklı Bilgi Araştırma Hedefi Statüsü (HAR-13)
HYBRID telemetri sızıntı modelinde hedeflenen karşılıklı bilgi denklemi:
$$\max_{\mathcal{A} \in \mathcal{M}_{\text{threat}}} I(S_{\text{raw}}; T_{\text{out}} \mid \mathcal{O}_{\text{side-channel}}) \le \epsilon_{\text{target}}$$
> [!WARNING]
> **Metrik Sınırları ve Doğrulama Durumu (HAR-13 Çözümü):**
> 1. **Onaylanmamış Araştırma Hedefi:** Sayısal hedef $\epsilon_{\text{target}}$, fiziksel örnekleme metodu, örneklem büyüklüğü, ölçüm protokolleri ve istatistiksel güven aralıkları ($1 - \alpha$) henüz standartlaştırılmamış bir **`UNVERIFIED RESEARCH / VALIDATION TARGET`** niteliğindedir. Onaylanmış bir ticari geçiş kriteri değildir.
> 2. **Kapsam Sınırı:** Kısıtlı bir saldırgan modeli ($\mathcal{M}_{\text{threat}}$) ve sınırlı bir gözlem kümesi ($\mathcal{O}$) altında karşılıklı bilginin sıfıra yakın bulunması, gerçek dünya koşullarındaki tüm olası fiziksel, donanımsal veya mantıksal covert-channel yollarının mutlak olarak ortadan kalktığını matematiksel olarak ispatlamaz.

---

## 3. Donanım İzolasyon Sınırları: Gate C İspatları vs. Sistem Gerçekliği (HAR-02, HAR-06..HAR-11)

RTL bloklarının yeteneklerinin sistem düzeyinde genel bir DMA güvenlik duvarı, bellek denetleyicisi veya telemetri filtresi gibi yansıtılmasını engellemek için, aşağıdaki teknik sınırlar açıkça kayıt altına alınmıştır:

| İncelenen RTL Blok | Gate C'de İspatlanan Gerçek Sınırlar (Formal Proof Scope & Simulation) | Harici Güven Varsayımları (Trust Assumptions) | İspatlanmamış Sistem, Telemetri & Fiziksel Riskler (Gate D Deliverables) |
| :--- | :--- | :--- | :--- |
| **`zc_spi_flash_firewall`** | - RDSR1 durum mutabakatı (`SR1[1:0] == 00`).<br>- SCK=0 iken yükselen /CS ile çerçeve tamamlama (`F-SPI-02`).<br>- İkincil hata durumunda donanımsal /CS deselect (`cs_n_flash_eff_o`).<br>- Bank B commit yetkilendirme kapısı (`bank_b_commit_ready_o`). | **HAR-04:** Kriptografik imza doğrulaması RTL içinde DEĞİLDİR. `rom_img_verif_valid_i` sinyalinin güvenilir bir Boot ROM motorundan geldiği harici bir güven varsayımıdır.<br>`bank_b_commit_ready_o = spi_idle_ready_o && rom_img_verif_valid_i`. | - Harici SPI Flash yongasının analog gecikmeleri.<br>- Eşzamanlı master çakışmaları (bus contention).<br>- PCB iletim hattı empedans bozulmaları ve glitch enjeksiyonu. |
| **`zc_obi_subordinate_bridge`** | - Tek çevrimlik istek teslimi (`F-OBI-01`).<br>- Öksüz yanıt emilimi (orphan drain) (`F-OBI-06`).<br>- Sıcak reset (`rst_sys_ni`) altında istek blokajı (`F-OBI-07`).<br>- `ST_TRAP` sentetik hata verisi üretimi.<br>- **HAR-06 Kanıt Sınıflandırması:** 1.024 çevrimlik kesintisiz watchdog timeout davranışı `tb_zc_obi.sv` Test 2 ile dijital RTL simülasyonu seviyesinde doğrulanmıştır (`SIMULATED`). `F-OBI-04` ve `F-OBI-05` ise 1024 çevrimin tamamının tek bir temporal ispatı değil, yerel RTL adım endüksiyonu (step-induction) ve kilitlenme bayrağı assertion ispatlarıdır (`PROVEN` at local RTL step level). | Gelen OBI ana isteklerinin geçerli bir CPU/DMA master'ından üretildiği varsayılır. | - **HAR-07 & HAR-11 Donanım Sınırı:** Bu blok telemetri filtreleme, izin listesi denetimi veya hız sınırlaması YAPMAZ (`PROPOSED / NOT IMPLEMENTED IN CURRENT RTL`). OBI köprüsü yalnızca bus protokolü seviyesinde ayrıştırma sağlar. Gate C yerel ispatları uçtan uca noninterference ispatı değildir.<br>- **HAR-02 Donanım Sınırı:** Bu blok bir SoC DMA güvenlik duvarı veya MPU DEĞİLDİR. Çok master'lı crossbar üzerindeki bellek erişim yetkilendirmesi açık bir sistem riskidir (`BLOCKED`). |
| **`zc_aon_post_auth_ctrl`** | - 4-fazlı DAI el sıkışma protokolü (`F-OTP-02/03`).<br>- Tek çevrimlik yetki tüketimi (`F-OTP-06`).<br>- Sıcak resette silinmeyen kalıcı fatal kilitlenme (`F-OTP-05`).<br>- Hsiao (22,16) kod sözcüğü parite denetimi (`F-OTP-04`).<br>- SVN anti-rollback monotonluğu (`F-OTP-01a/b`). | DAI arayüzünün fiziksel OTP analog makrosuna doğrudan bağlı olduğu ve harici hata sinyallerinin (`volt_supervisor_fault_i`, `tamper_alert_i`) doğru çalıştığı varsayılır. | - Fiziksel antifuse programlama şarj pompası ($V_{\text{PP}} > 1.8\,\text{V}$) analog darbe süresi.<br>- Dökümhane (foundry) OTP makro hücresi güvenilirliği ve veri saklama (retention) fiziği. |

---

## 4. Dosya Bazlı Mevcut Belge Güncelleme Planı (Remediation Plan)

Bağımsız denetçinin ve standartlar komitesinin nihai onayından sonra, mevcut 8 temel normatif belge aşağıdaki plan doğrultusunda tek bir atomik commit ile güncellenecektir:

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
4. Bağımsız denetçinin bu düzeltmeler üzerindeki resmi onayı alınmadan ve HAR-08..13 kararları netleşmeden ana normatif dokümanlarda hiçbir satır değiştirilmeyecektir.
