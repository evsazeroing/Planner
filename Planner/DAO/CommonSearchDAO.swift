
import Foundation

protocol CommonSearchDAO: Crud{

    func search(text:String, sortType:SortType?) -> [Item]  // поиск по тексту
    
}
