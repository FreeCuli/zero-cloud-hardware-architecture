# FREECULI ZERO-CLOUD CONFORMANCE TEST SPECIFICATION (FC-ZC-CTS v1.0)
**Draft Experimental Methodology for Verifiable Physical Privacy**

> **"FreeCuli does not require you to trust FreeCuli. It requires you to reproduce the test."**

Bu şartname, FC-ZC v1.0 standardına uymak isteyen herhangi bir donanımın (akıllı fırın, asistan, beyaz eşya vb.) laboratuvar ortamında geçmesi gereken **yanlışlanabilir (falsifiable) ve tekrarlanabilir (reproducible)** saldırı ve test senaryolarını tanımlar.

---

## 🔬 TEST PROTOKOLLERİ VE LABORATUVAR METODOLOJİSİ

### FC-ZC-001: Threat Model (Network SoC Exploitation)
**Hedef:** Ağ işlemcisinin (Wi-Fi/Bluetooth SoC) tamamen ele geçirilmesi durumunda bile sensör verisinin (ham ses/görüntü) izole bölgeden dışarı çıkarılamadığının ispatı.
* **Test Setup (Düzenek):** Cihaz standart ev ağına bağlanır. Main MCU / Network SoC birimi üzerindeki JTAG/UART portları fiziksel olarak aktif edilir veya ağ üzerinden sıfır gün (zero-day) yetki yükseltme (Root) simülasyonu çalıştırılır.
* **Attack Model (Saldırı Modeli):** Ağ çipinde en yüksek çekirdek (Kernel) yetkisiyle, izole NPU (Edge AI) belleğine (RAM/SRAM) ve sensör veriyollarına (I2C/SPI/I2S) yönelik aktif okuma, bellek dökümü (memory dump) ve rastgele komut enjeksiyonu saldırıları gerçekleştirilir.
* **Measuring Device (Ölçüm Cihazı):** Lojik Analizör (En az 500 MS/s), JTAG/SWD Debugger.
* **Pass/Fail Threshold (Eşik):** 
    * **PASS:** Network SoC üzerinden yapılan hiçbir sorgu, NPU belleğinden veya sensör veri hatlarından tek bir bit bile okuyamaz (Hardware Fault/Timeout alınır).
    * **FAIL:** Ağ işlemcisi, NPU belleğinin herhangi bir adres bloğuna "Read" (Okuma) erişimi sağlayabilir.

---

### FC-ZC-002: Sensor / Network Domain Separation (Electrical Air-Gap)
**Hedef:** Ağ yongası ile sensörler arasında hiçbir fiziksel, elektriksel veya parazitik (cross-talk) veri yolunun olmadığının kanıtlanması.
* **Test Setup (Düzenek):** Cihazın güç bağlantısı kesilir ve PCB (Baskı Devre Kartı) cihazdan tamamen ayrılır.
* **Attack Model (Saldırı Modeli):** Kamera (MIPI CSI) ve Mikrofon (I2S/PDM) pinlerinden, Main MCU ve Wi-Fi/BLE çipi pinlerine doğru yüksek frekanslı RF sinyalleri basılır ve iletkenlik (continuity) taraması yapılır.
* **Measuring Device (Ölçüm Cihazı):** Vektör Ağ Analizörü (VNA), TDR (Time-Domain Reflectometer), PCB X-Ray (Çok katmanlı kartlar için).
* **Pass/Fail Threshold (Eşik):**
    * **PASS:** Sensör pinleri ile Network Domain pinleri arasındaki empedans ölçümü "Sonsuz" (Açık Devre) çıkmalı, kapasitif veya indüktif sinyal sızıntısı gürültü tabanının (Noise Floor) altında olmalıdır.
    * **FAIL:** Katmanlar arası (via) veya yan yana giden yollar yüzünden (cross-talk) sensör sinyalinin ağ çipinin pinlerinde okunabilir bir voltaj yaratması.

---

### FC-ZC-003: Unidirectional Data Flow (Donanımsal Veri Diyotu)
**Hedef:** NPU'dan Main MCU'ya sadece işlenmiş komutların (örn: "Işığı Aç") gidebildiğini, Main MCU'dan NPU'ya geriye doğru hiçbir verinin sızamadığını doğrulamak.
* **Test Setup (Düzenek):** NPU ile Main MCU arasındaki izolasyon bariyerinin (Optokuplör vb.) her iki tarafındaki TX ve RX pinlerine proplar bağlanır.
* **Attack Model (Saldırı Modeli):** "Reverse-channel injection" (Ters kanal enjeksiyonu). Main MCU tarafındaki alıcı (RX) pini üzerinden, donanımsal diyota doğru ters yönde 3.3V / 5V yüksek frekanslı sahte veri paketleri (Fuzzing) zorla basılır.
* **Measuring Device (Ölçüm Cihazı):** Çok kanallı Osiloskop (En az 1 GHz bant genişliği), Yüksek hızlı Sinyal Jeneratörü.
* **Pass/Fail Threshold (Eşik):**
    * **PASS:** Main MCU tarafından basılan veri veya voltaj, NPU tarafındaki TX pininde tam bir sessizlik (0V veya sabit Logic High) yaratır. Geriye doğru sinyal geçişi fiziksel olarak bloke edilir.
    * **FAIL:** Ters yönde basılan sinyaller NPU pini üzerinde milivolt seviyesinde bile olsa okunabilir mantıksal dalgalanmalara (Logic State Change) yol açar.

---

### FC-ZC-004: Volatile Data Destruction (SRAM Kalıntı Eşiği)
**Hedef:** Yapay zeka modeli çıkarımı (inference) bitirdiği anda, sensör verisinin tutulduğu uçucu belleğin gücünün kesilip verinin kurtarılamaz şekilde silindiğini doğrulamak.
* **Test Setup (Düzenek):** NPU içindeki/dışındaki Volatile Buffer (SRAM) güç hattına (VCC) osiloskop probu bağlanır. Sensöre 5 saniyelik referans bir ses/görüntü verilir.
* **Attack Model (Saldırı Modeli):** Çıkarım (inference) sinyali gönderildiği milisaniyede (Cut-off Event), cihazın güç kaynağına sıvı nitrojen uygulanarak bellek dondurulur (Cold-Boot Attack) ve fiziksel bellek dökümü alınmaya çalışılır.
* **Measuring Device (Ölçüm Cihazı):** Sıvı Nitrojen, Yüksek hızlı Lojik Analizör, JTAG bellek döküm modülü.
* **Pass/Fail Threshold (Eşik):**
    * **PASS:** Donanımsal kesme (Interrupt) anında SRAM VCC voltajı 10 mikrosaniye içinde 0V'a düşer. Cold-Boot atağı sonucunda elde edilen bellek dökümünde, referans ses/görüntünün matematiksel kalıntı oranı (Mathematical Remanence Threshold - $\tau_{rem}$) %0.01'in altındadır (Geri döndürülemez kriptografik gürültü).
    * **FAIL:** Güç kesintisi gecikir veya kalıntı şarj nedeniyle sensör verisinin yapısal özellikleri (ses frekansı, görüntü matrisi) bellek dökümünden kısmen bile olsa geri kazanılabilir.

---

### FC-ZC-009: Side-Channel & Metadata Leakage (Yan Kanal ve Metaveri Sızıntısı)
**Hedef:** Elektromanyetik yayılımlar veya güç tüketimindeki dalgalanmalar üzerinden ev içindeki faaliyetlerin (ne konuşulduğu, kimin odada olduğu) tahmin edilemeyeceğini doğrulamak.
* **Test Setup (Düzenek):** Cihaz yankısız ve elektromanyetik yalıtımlı (Faraday) bir test odasına alınır. Sensörlere bilinen farklı ses komutları (örn: sessizlik, normal konuşma, gürültü) verilir.
* **Attack Model (Saldırı Modeli):** Differential Power Analysis (DPA) ve Simple Power Analysis (SPA). Cihazın çektiği akımdaki dalgalanmalar ve yaydığı elektromanyetik sinyaller (Tempest Attack) yüksek hassasiyetle kaydedilir ve yapay zeka sınıflandırıcıları ile (Machine Learning) ses verisi geri oluşturulmaya (reconstruct) çalışılır.
* **Measuring Device (Ölçüm Cihazı):** Elektromanyetik (EM) Prob, Akım Trafosu, Osiloskop, Spektrum Analizörü.
* **Pass/Fail Threshold (Eşik):**
    * **PASS:** Elde edilen güç/EM dalgalanmaları ile içerideki ses faaliyeti arasındaki Karşılıklı Bilgi (Mutual Information - $I(X;Y)$) istatistiksel sıfır noktasına yakındır. Saldırgan algoritma, sesin içeriğini rastgele tahminden (Random Guessing) daha yüksek bir doğrulukla sınıflandıramaz.
    * **FAIL:** Güç tüketimi eğrileri analiz edilerek, evde birinin olup olmadığı veya hangi kelimelerin söylendiği (örn: "Işığı Aç" veya "Alarmı Kur") dışarıdan %50'den yüksek bir başarı oranıyla tahmin edilebilir.

---

> **Not:** Bu doküman, FreeCuli GitHub deposunda `FC-ZC-Conformance-Test-Specification.md` adıyla bağımsız bir standart olarak yayınlanmak üzere kurgulanmıştır. Bu metin, donanım üreticilerine gönderilecek olan "Meydan Okuma ve Sertifikasyon" paketinin kalbidir.
