//
//  TermsDescriptionTextView.swift
//  Depo_LifeTech
//
//  Created by Maxim Soldatov on 6/14/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//


import UIKit

final class TermsDescriptionController: BaseViewController {
    
    private var textToPresent: String = ""
   
    init(text: String = "") {
        textToPresent = text
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private let textView: UITextView = {
        let textView = UITextView()
        textView.isEditable = false
        textView.font = UIFont.TurkcellSaturaRegFont(size: 15)
        textView.textColor = AppColor.blackColor.color
        textView.backgroundColor = AppColor.primaryBackground.color
        return textView
    }()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = AppColor.primaryBackground.color
        setupLayout()
        if textToPresent.isEmpty {
            let navbarTitle = UILabel()
            navbarTitle.text = "lifebox'lılar kazanıyor çekiliş kampanyası detayları"
            navbarTitle.font = .appFont(.medium, size: 14)
            navbarTitle.minimumScaleFactor = 0.5
            navbarTitle.adjustsFontSizeToFitWidth = true
            navigationItem.titleView = navbarTitle
            
            textView.font = .appFont(.light, size: 14)
            textView.text = milliPiyangoText()
            textView.textAlignment = .justified
        } else {
            textView.attributedText = textToPresent.htmlAttributedForPrivacyPolicy(using: UIFont.TurkcellSaturaFont(size: 15))
            setTitle(withString: TextConstants.termsOfUseCell)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    private func setupLayout() {
        view.addSubview(textView)

        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).activate()
        textView.topAnchor.constraint(equalTo: view.topAnchor, constant: 8).activate()
        textView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15).activate()
        textView.bottomAnchor.constraint(equalTo: view.bottomAnchor).activate()
    }
    
    private func milliPiyangoText() -> String {
        return
            """
            • Bu kampanya Lifecell Bulut Çözümleri A.Ş.adına MPİ’nin 29.09.2023 tarih ve E- 58259698-255.01.02-44421sayılı izni ile Hedef Çekiliş tarafından düzenlenmektedir.
            • Kampanya 04.10.2023 (saat 00:01) - 04.12.2023 (saat 23:59) tarihleri arasında Türkiye genelinde Lifecell Bulut Çözümleri A.Ş 'ye ait ait Lifebox Uygulaması kullanımını teşvik etmek amacı ile  iOS veya Androrid sistemli cihazlarına en güncel Lifebox uygulamasını ücretsiz indirerek uygulamaya yeni üye olan veya mevcut üyelere; 532 (ücretsiz) çağrı merkezi numarasını arayarak, mylifebox.com(ücretsiz) internet sitesi üzerinden üzerinden, turkcell.com.tr(ücretsiz) internet sitesi üzerinden veya 2200 SMS hattına kısa mesaj atarak Lifebox aylık paket alımlarına 1 çekiliş hakkı, Lifebox yıllık paket alımlarına 2 çekiliş hakkı verilecektir. (Kampanya tüm GSM operatörlerinin bireysel hat sahibi olan Lifebox bireysel üyelerine yönelik olup çekilişe katılmaya hak kazanmak için kampanya tarihleri arasında paketin aktif olması gerekmektedir.)
            • Talihliler, 13.12.2023 tarihinde Hedef Çekiliş ve Organizasyon Hizm. Ltd. Şti. (Toplantı Salonu)-Esentepe Mah. Kore Şehitleri Cad. No: 16/1 İç Kapı K8 Şişli/İstanbul adresinde saat 11:00’da noter huzurunda halka açık olarak yapılacak çekilişle belirlenecektir.
            • Kampanya genelinde yapılacak olan çekilişle,1 kişiye 300.000,00 TL değerinde 1 çift kişilik Başka Türlü Macera Seyahat hediye çeki (Hediye çeki rezervasyon işlemlerinizi https://www.baskaturlumacera.com/siradaki-geziler/ linki üzerinden veya 90 212 251 9447 numara üzerinden ya da Bereketzade Mah. Büyük Hendek Cad. No:17/4 Beyoğlu-İstanbul adresinden işlemler gerçekleştirilebilir. Hediye çeki; tüm yurt dışı turlarında geçerlidir. Adlarına özel tanımlanacak olan Başka Türlü Macera Turizm Ltd. Şti üzerinden İstanbul Kalkışlı yurt dışı münferit uçak biletleri, tüm yurt dışı otel konaklamaları, Yurt dışı paket programları (otel, uçak, transfer şehir içi ve şehirlerarası, Profesyonel Türkçe Rehberlik Hizmetleri, Zorunlu Seyahat sağlık Sigortası, kahvaltı, öğle ve akşam yemekleri, yurt dışı çıkış harcı, vize ücretleri dahildir, pasaport ücreti talihliye aittir.) kategorilerinde kullanılabilecek hediye çeki verilecektir. 15.01.2024 – 22.08.2024 tarihleri arasında geçerlidir.),
            • 1 kişiye 43.999,00 TL değerinde Apple Iphone 14 128 GB,
            • 1 kişiye 26.658,76 TL değerinde Sony Playstation 5 PS5 Oyun Konsolu+2 Dualsence Kol ,
            • 1 kişiye 12.000,00 TL değerinde Tatilsepeti Kapadokya Seyahat Çeki (adlarına özel tanımlanacak olan, 444 44 20 çağrı merkezlerimiz üzerinden sadece Kapadokya kültür  Turları için kullanılmak üzere sınırlı 15.01.2024 – 22.08.2024 tarihleri arasında geçerli 12.000TL tutarında 1 çift kişilik hediye çeki),
            • 1 kişiye 10.499,00 TL değerinde Apple Watch SE 44 MM ikramiyesi verilecektir.
            • İkramiye kazanan talihliler, 15.12.2023 tarihli Takvim Gazetesi’nde ilan edilecektir. Kampanya tüm GSM operatörlerinin bireysel tarifeli hat sahibi olan Lifebox bireysel uygulaması üyelerine yönelik olup çekilişe katılmaya hak kazanmak için kampanya tarihleri arasında paketin aktif olması gerekmektedir.532 çağrı merkezi araması ücretsizdir. Kampanya hat sahipleri için geçerli olup ikramiye tesliminde kazanan kişinin hat sahibi olduğu konusunda belge ibrazı zorunludur. Kısa mesaj ile Turkcell, Türk Telekom, Vodafone operatörlerinin tüm aboneleri, 2200 SMS göndererek Lifebox paket alımı yapabilir. Kısa mesaj ile başarılı ya da hatalı tüm alımlar KDV ve ÖİV dahil; Turkcell aboneleri için 1,99 TL, Türk Telekom aboneleri için 1,00 TL, Vodafone aboneleri için 0,65 TL olarak katılımcıya ücretlendirilir. Operatörlerin katılım mesajı birim fiyatlarında değişiklik hakkı saklıdır. Kampanya tarihleri arasında paket değişikliğine gidilmesi durumunda, son geçerli paketi üzerinden çekiliş hakkı verilecektir. Kampanya bitiş tarih ve saatinden itibarinden 48 saat içerisinde paket iptali yapılması halinde çekiliş hakkı iptal edilecektir. Tüm katılımlarda Ad-Soyad ve telefon no bilgilerinden herhangi birinin eksik olması halinde çekiliş hakkı verilmeyecektir. Katılımcının ikramiye kazanması durumunda adres bilgileri, eksik veya bilinmiyor ise gazetede yapılan ilan tebliğ için yeterli olacaktır. Seyahat çeki ikramiyesini talihliden başkası kullanamaz, nakde çevrilemez veya devredilemez. Bir kişi birden fazla ikramiye kazanamaz. Lifecell Bulut Çözümleri A.Ş. ve Hedef Çekiliş ve Organizasyon Hizmetleri LTD. ŞTİ. çalışanları ile 18 yaşından küçükler düzenlene piyango ve çekilişe katılamaz, katılmış ve kazanmış olsalar dahi ikramiyeleri verilemez. İkramiyeye konu olan eşya ve /veya hizmetin bedeli içinde bulunan KDV+ÖTV gibi vergiler dışındaki vergiler talihliler tarafından ödenecektir.
            """
    }
}


