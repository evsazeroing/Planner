
import Foundation

// общий протокол для поиска элементов
protocol CommonSearchDAO: Crud{

    func search(text:String, sortType:SortType?) -> [Item]  // поиск по тексту
    
}
