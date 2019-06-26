
import Foundation
import L10n_swift
import FlagKit


// утилита для работы с языками и флагами
class LangManager{

    var langArray = [String]() // массив кодов для языков
    var flagArray = [Flag]() // массив флагов

    // синглтон
    static let current = LangManager()

    private init(){
        initLanguages()
    }


    var count:Int{
        return langArray.count
    }



    // название языка по индексу
    func name(_ index:Int) -> String {
        return LangManager.current.name(langArray[index])
    }

    // название языка по коду
    func name(_ code:String) -> String{

        return (L10n.shared.locale?.localizedString(forLanguageCode: code)?.capitalized)!
    }

    // картинка флага
    func flag(_ index:Int) -> UIImage{
        return flagArray[index].image(style: .roundedRect)
    }

    // картинка флага
    func flag(_ code:String) -> UIImage{
        return flag(langArray.index(of: code)!)
    }

    // загрузка доступны языков
    func initLanguages(){

        langArray = L10n.supportedLanguages // доступные языки для приложения


        for langCode in langArray{

            let flag: Flag

            switch langCode{
            case "en":
                flag = Flag(countryCode: "US")!
            case "ru":
                flag = Flag(countryCode: "RU")!
            default: fatalError("lang type")
            }

            flagArray.append(flag)
        }

        //TODO: сортировать по алфавиту список языков
    }





}

