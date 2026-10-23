# FREECULI ZC-CORE — Gate C Nihai Kapanış ve Mutabakat Kaydı

**Tarih:** 20 Ekim 2026
**Proje:** FreeCuli ZC-CORE (Zero-Cloud Hardware Core)
**Belge Türü:** Teknik denetim kapanış ve yönetişim kaydı
**Belge Kimliği:** ZC-CORE-GATE-C-FINAL-AUDIT-CLOSURE
**Gate C Kararı:** **PARTIAL / QUALIFIED — SIGN-OFF ACCEPTED**
**GCR-01 – GCR-11:** **CLOSED — Tanımlı denetim kapsamları dahilinde**
**Teknik Doğrulama Temeli:** Commit [`eb3ed5ad9fddb551506d43d2692bd040843af06f`](https://github.com/FreeCuli/zero-cloud-hardware-architecture/commit/eb3ed5ad9fddb551506d43d2692bd040843af06f) — [CI Run #45 (ID: 39321501893)](https://github.com/FreeCuli/zero-cloud-hardware-architecture/actions/runs/39321501893)
**Dokümantasyon Referansı:** Commit [`324e3c988c80ad312984920b79cf4a54c600f913`](https://github.com/FreeCuli/zero-cloud-hardware-architecture/commit/324e3c988c80ad312984920b79cf4a54c600f913)
**Gate D:** **UNVERIFIED**
**Yönetişim (Tarihsel Gate C Kapanışında):** **DO NOT MERGE / RELEASE BLOCKED (Tarihsel Şart)**

> [!NOTE]
> **Tarihsel Yönetişim Kaydı (Gate C Kapanış Bağlamı):**
> Bu belgedeki "DO NOT MERGE / RELEASE BLOCKED" kısıtlaması, 20 Ekim 2026 tarihinde `gate-c/formal-scope-audit` dalının kapatılması sırasındaki tarihsel denetim koşulunu kayıt altına almaktadır. Bu kısıtlama o tarihteki kapı durumunu belgeler; sonraki sürüm adayı (`v4.0.0-rc2`) geliştirme ve yayın hazırlık süreçlerini geçmişe dönük olarak kısıtlamaz.

---

## 1. Nihai Denetim Kararının Kaydı

FreeCuli ZC-CORE donanım mimarisi için yürütülen Gate C bağımsız teknik inceleme sürecinde, **GCR-01'den GCR-11'e kadar tüm bulgular**, her bir bulgu için belirlenen kapsam, modelleme sınırları ve doğrulama ortamı dahilinde **CLOSED** olarak değerlendirilmiş ve kabul edilmiştir.

Gate C'nin mevcut ve gerçekleştirilebilir açık kaynak RTL, formal doğrulama ($k$-induction, BMC, SMT2) ve döngü-doğrusal dijital simülasyon alt kapsamı, belgelenmiş sınırlar dahilinde tamamlanmıştır.

> [!IMPORTANT]
> **Kapsam ve Statü Açıklığı:**
> Bu karar, **bağımsız teknik inceleme kapsamında kabul edilmiş** bir mimari ve mantıksal doğrulama mutabakatıdır; resmî bir akreditasyon kuruluşunun veya üçüncü taraf sertifikasyon otoritesinin verdiği bir haricî güvenlik sertifikasyonu değildir.
> Bu karar, Gate C genel güvenlik hedeflerinin bütünüyle tamamlandığı, bütün olası RTL davranışlarının fiziksel/analog düzeyde ispatlandığı veya silikon güvenlik sertifikasyonu verildiği anlamına **gelmez**.

Konsolide 33 iddianın normatif sınıflandırması:
- **`PROVEN`:** 19 (Formal endüktif değişmezler ve sembolik ispatlar)
- **`SIMULATED`:** 4 (Döngü-doğrusal dinamik HDL simülasyonları)
- **`BOUNDED`:** 4 (Sınırlı formal cover şahitleri ve modellenmiş ufuk sınırları)
- **`BLOCKED`:** 2 (Tam SoC 2-trace miter entegrasyon özellikleri)
- **`UNVERIFIED`:** 4 (Fiziksel silikon, dökümhane analog makro, STA ve LEC parametreleri)
- **TOPLAM:** 33 benzersiz normatif güvenlik iddiası

Bu sınıflandırmaların teknik geçerliliği, [`CONSOLIDATED_NORMATIVE_EVIDENCE_MATRIX.md`](CONSOLIDATED_NORMATIVE_EVIDENCE_MATRIX.md) ve [`MODELING_LIMITS.md`](MODELING_LIMITS.md) belgelerinde açıklanan kaynak, varsayım, çözücü soyutlamaları (`async2sync`) ve kanıt sınırlarıyla birlikte bir bütün olarak bağlayıcıdır.

---

## 2. Açık Kalan Doğrulama Yükümlülükleri (Gate D Deferral)

Aşağıdaki doğrulama yükümlülükleri açık kaynak dijital Gate C kapanış kararının kapsamı dışında kalmakta olup, kesin sınırlarla **Gate D (UNVERIFIED)** kapsamına ertelenmiştir:

1. **Tam SoC İki-İzli Non-Interference Doğrulaması (`BLOCKED`):**
   Çift çekirdekli Ibex CPU, NPU koproserü ve güvenli SRAM crossbar'ını içeren tam SoC seviyesindeki `SVA-M7-01` ve `SVA-M8-01` miter modelleri.
2. **Gerçek OTP/Antifuse Makrosunun Analog ve Fiziksel Karakterizasyonu (`UNVERIFIED`):**
   $V_{\text{PP}} > 1.8\,\text{V}$ yüksek gerilim şarj pompası regülasyonu, programlama darbe süresi ($t_{\text{PROG}} \approx 10\,\mu\text{s}$), termal soak ve algılama marjinleri.
3. **Gate-Level Mantıksal Eşdeğerlik Doğrulaması (LEC) (`UNVERIFIED`):**
   Dökümhane PDK standard hücre kütüphanesine karşı post-synthesis netlist eşdeğerliği (Synopsys Formality / Cadence Conformal).
4. **Statik Zamanlama Analizi (STA) ve PVT Analizi (`UNVERIFIED`):**
   Asenkron reset removal/recovery ($t_{\text{rem}}, t_{\text{rec}}$) zamanlama kapanışı ve saat alanları arası (CDC) metastabilite doğrulaması.
5. **FPGA, Laboratuvar ve Gerçek Donanım Üzerinde Doğrulama:**
   Fiziksel kart üzerinde SPI Flash, voltaj glitching ve lojik analizör ile donanım düzeyinde doğrulama.

Bu yükümlülükler Gate C kapsamında tamamlanmış olarak gösterilemez; bunların tamamlanması için gerekli teknik ön koşullar Gate D giriş planında ayrıca tanımlanacaktır.

---

## 3. Referansların ve Yönetişimin Korunması

1. **Teknik Baseline:** Run #45 (`eb3ed5ad9fddb551506d43d2692bd040843af06f`), Gate C'nin dondurulmuş teknik doğrulama temeli olarak muhafaza edilecektir.
2. **RTL ve Formal Dondurma:** Gate C referans RTL'si ([`rtl/`](../../rtl/)) ve formal harness'leri ([`fv/`](../../fv/)), yeni bir resmî değişiklik kontrol kararı (RFC/ECN) olmaksızın değiştirilmeyecektir.
3. **Dal ve Sürüm Kilidi:** `gate-c/formal-scope-audit` çalışma dalı `main` dalına birleştirilmeyecektir (**DO NOT MERGE**). `v3.4.0` veya `v4.0.0` genel sürümleri için sürüm yayınlama yetkisi verilmemiştir (**RELEASE BLOCKED**).
4. **Çalışma Serbestisi:** Bu kısıtlamalar, doğrulama planlarının, savunma amaçlı teknik yayın paketlerinin ve Gate D hazırlık belgelerinin bağımsız olarak hazırlanmasına engel teşkil etmez.

---

## 4. Zenodo Savunma Amaçlı Yayın Ön Hazırlığı (Defensive Publication Preflight)

Bir sonraki aşamada **FreeCuli ZC-CORE: Gate C Formal Verification Report & Technical Specification (Defensive Publication)** başlıklı teknik yayın paketi hazırlanacaktır.

Bu paket, kamuya açıklanmadan önce aşağıdaki sıkı kontrollerden geçirilecektir:
- Kamuya açıklanabilecek teknik bilgilerin kapsamı ve sınırları.
- Normatif iddialarla (`ZC-CLAIM-01..33`) depodaki gerçek teknik kanıtların birebir uyumu.
- Kaynak commit'lerinin, git tag'lerinin ve kanıt dosyalarının tam izlenebilirliği.
- Açık donanım lisansı (CERN-OHL-S v2.0), üçüncü taraf fikri mülkiyet hakları ve ticari çift-lisanslama stratejisi.
- Savunma amaçlı yayının patent stratejisine, üçüncü taraflarca olası türev patent başvurularına ve savunma bariyerine etkileri.
- DOI, sürüm, yazar listesi, yayın tarihi ve kriptografik arşiv bütünlüğü (SHA-256).

> [!WARNING]
> **Yayın Öncesi Hukuki ve Teknik Sınır:**
> Yayın ön hazırlığı, Zenodo üzerinde otomatik veya koşulsuz bir yayımlama yetkisi teşkil etmez.
> Defensive publication (savunma amaçlı yayın), kamuya açıklama yoluyla dünya çapında bir *olası prior-art (tekniğin bilinen durumu)* kaydı oluşturmayı hedefler; ancak tek başına otomatik ve mutlak bir patent koruması veya her ülkede koşulsuz bir patent geçersiz kılma garantisi olarak sunulamaz.

---

## 5. Gate D Giriş Planı (Roadmap)

`GATE_D_ENTRY_CRITERIA.md` ve fiziksel doğrulama planı müstakil bir teknik çalışma paketi olarak hazırlanacaktır.

Bu plan asgari olarak şu başlıkları kapsayacaktır:
- FPGA prototipleme mimarisi ve donanım test ortamı (Xilinx/Alveo veya açık kaynak donanım çekirdeği).
- SPI ve OBI fiziksel gözlem ve lojik analizör sinyal yakalama senaryoları.
- Sıcak/soğuk reset transients, brown-out ve glitch fault injection test prosedürleri.
- Analog OTP makro fiziksel sınırları ve dökümhane PDK bağımlılıkları.
- Tam SoC entegrasyonu için Ibex CPU, NPU koproserü ve crossbar arayüz şartnameleri.
- Ölçüm kabul toleransları ve bağımsız laboratuvar kanıtlarının izlenebilirlik kuralları.

---

## 6. Nihai Yönetişim ve Mutabakat Özeti

```
========================================================================================
 FREECULI ZC-CORE — GATE C FINAL AUDIT CLOSURE & GOVERNANCE RECORD
========================================================================================
 Denetim Durumu : GCR-01 through GCR-11 CLOSED (Within Scoped Modeling Limits)
 Gate C Statüsü : PARTIAL / QUALIFIED — SIGN-OFF ACCEPTED
 Gate D Statüsü : UNVERIFIED (Deferred to Physical Silicon / Full-SoC Validation)
 Branch Status  : DO NOT MERGE (gate-c/formal-scope-audit remains isolated)
 Release Status : RELEASE BLOCKED (v3.4.0 / v4.0.0 Release Authorization NOT Granted)
 Technical Base : eb3ed5ad9fddb551506d43d2692bd040843af06f (Run #45 Verified)
 Doc Baseline   : 324e3c988c80ad312984920b79cf4a54c600f913
========================================================================================
 Bu kayıt, gelecekteki fiziksel doğrulama (Gate D) ve savunma amaçlı teknik yayın
 (Zenodo Defensive Publication) çalışmalarının resmî başlangıç referansıdır;
 yeni bir güvenlik sertifikası veya ticari silikon sürüm onayı değildir.
========================================================================================
```
