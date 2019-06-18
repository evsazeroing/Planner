
import Foundation

protocol CommonSearchDAO: Crud{

    func search(text:String) -> [Item]  // поиск по тексту
    
}
