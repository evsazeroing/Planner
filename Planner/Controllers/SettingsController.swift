
import UIKit
import L10n_swift

// настройки приложения
class SettingsController: UITableViewController {

    private let sectionLang = 0

    private let langIndexPath:IndexPath = IndexPath(row: 0, section: 0)


    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: tableView

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        switch indexPath.section {
        case 0:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "cellCurrentLang", for: indexPath) as? CurrentLangCell else{
                fatalError("cell type")
            }

            let code = (L10n.shared.locale?.languageCode)! // текущий язык приложения

            cell.labelLangName.text = LangManager.current.name(code) // название языка с большой буквы в нужной локали

            cell.imageFlag.image = LangManager.current.flag(code) // получаем флаг по коду языка

          
            return cell

        default:

            fatalError("section")
        }

    }



    // заголовки секций
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == sectionLang{
            return lsLang
        }

        return ""
    }




    // MARK: prepare

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? LangListController{
            controller.selectedLang = L10n.shared.language
        }

    }


}




