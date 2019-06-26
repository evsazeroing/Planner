
import UIKit
import L10n_swift
import Toaster

// список доступных языков для приложения
class LangListController: UITableViewController {


    var selectedLang:String!

    private let sectionLangList = 0

    private var currentCheckedIndexPath:IndexPath! // последний/текущий выделенный элемент (галочка)

    private let langManager = LangManager.current


    override func viewDidLoad() {

        super.viewDidLoad()

        tableView.allowsMultipleSelection = false // можно выделять только 1 строку

        createSaveCancelButtons(save: #selector(tapSave))

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }



    @IBAction func tapCheck(_ sender: UIButton) {

        let buttonPosition : CGPoint = sender.convert(sender.bounds.origin, to: tableView)
        let indexPath = tableView.indexPathForRow(at: buttonPosition)

        checkLang(indexPath!) // сменить язык приложения
    }


    // нажали сохранить - нужно обновить язык приложения
    @objc private func tapSave(){

        if L10n.shared.language != selectedLang{ // если поменялся язык

            PrefsManager.current.lang = selectedLang // сохранить в настройки, чтобы при след. запуске считать

            L10n.shared.language = selectedLang // записать текущий язык в L10n - чтобы он понимал, какой файл strings использовать для перевода
            
            // переходим в корневой контроллер с анимацией и сменой языка UI
            UIView.transition(with: UIApplication.shared.windows[0], duration: 0.5, options: .transitionFlipFromRight, animations: {

                // открываем первый контроллер со списком задач
                UIApplication.shared.windows[0].rootViewController = UIStoryboard(
                    name: "Main",
                    bundle: nil
                    ).instantiateViewController(withIdentifier: "FirstNavigationController")}, completion: nil)


            Toast(text: lsLangChanged, delay: 0, duration: Delay.short).show() // сообщение пользователю о том, что язык сменился

            LangManager.current.initLanguages() // обновить список языков в нужном переводе

        }else{ // если язык не поменялся - просто закрываем
            closeController()
        }

    }



    // MARK: tableView

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    // кол-во записей для секций
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return langManager.count // сколько доступных языков
    }

    // заполнение каждой строки - список доступных языков приложения
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellLang", for: indexPath) as! LangListCell

        let code = (L10n.shared.locale?.languageCode)! // текущий язык приложения

        if selectedLang != nil && selectedLang ==  langManager.langArray[indexPath.row]{
            cell.buttonCheck.setImage(UIImage(named: "check_green"), for: .normal)
            currentCheckedIndexPath = indexPath
        }else{
            cell.buttonCheck.setImage(UIImage(named: "check_gray"), for: .normal)
        }

        cell.selectionStyle = .none // чтобы не выделялась строка при нажатии (т.к. у нас будет включаться/выключаться иконка)

        cell.labelLangName.text = langManager.name(indexPath.row) // вывод полного названия языка с большой буквы (берем из словаря)

        cell.imageFlag.image = LangManager.current.flag(indexPath.row) // получаем флаг по индексу

        return cell
    }


    // заголовки
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == sectionLangList{
            return lsSelectLang
        }

        return ""
    }


    //  нажатие на строку
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        checkLang(indexPath)
    }


    // выделить ячейку
    private func checkLang(_ indexPath:IndexPath){
        let lang = langManager.langArray[indexPath.row]


        if indexPath != currentCheckedIndexPath{ // если текущая строка не была выделена

            selectedLang = lang


            if let currentCheckedIndexPath = currentCheckedIndexPath{// снимаем выделения для прошлой выбранной строки (если такая была)
                tableView.reloadRows(at: [currentCheckedIndexPath], with: .none)
            }

            currentCheckedIndexPath = indexPath

            // обновляем вид нажатой строки
            tableView.reloadRows(at: [indexPath], with: .none)


        }



    }

}



