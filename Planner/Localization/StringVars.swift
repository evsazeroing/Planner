
// для storyboards не нужно создавать переменные (это только для использования в коде), т.к. там - прямые на ключи


import L10n_swift



// общие

var lsClose:String{return "close".l10n()}
var lsName:String{return "name".l10n()}
var lsSave:String{return "save".l10n()}
var lsFillName:String{return "fillName".l10n()}
var lsAZ:String{return "A_Z".l10n()}
var lsEdit:String{return "edit".l10n()}
var lsSearchByName:String{return "searchByName".l10n()}
var lsAdd:String{return "add".l10n()}
var lsSelectAll:String{return "selectAll".l10n()}
var lsDeselectAll:String{return "deselectAll".l10n()}
var lsStartTypingName:String{return "startTypingName".l10n()}
var lsCancel:String{return "cancel".l10n()}
var lsTapToFill:String{return "tapToFill".l10n()}
var lsConfirm:String{return "confirm".l10n()}
var lsDate:String{return "date".l10n()}
var lsShareText:String{return "shareText".l10n()}
var lsToday:String{return "today".l10n()}
var lsTomorrow:String{return "tomorrow".l10n()}
var lsDays:String{return "days".l10n()}
var lsNotSelected:String{return "notSelected".l10n()}
var lsInfo:String{return "info".l10n()}
var lsSelectColor:String{return "selectColor".l10n()}
var lsNoData:String{return "nodata".l10n()}
var lsSelectValue:String{return "selectValue".l10n()}
var lsSelectDate:String{return "selectDate".l10n()}



// категории

var lsNewCategory:String { return "newCategory".l10n()}
var lsCategory:String { return "category".l10n()}
var lsSelectCategory:String { return "selectCategory".l10n()}
var lsNoCategory:String { return "noCategory".l10n()}
var lsCategories:String { return "categories".l10n()}


// пункты меню

var lsMenuCommon:String{return "menu.common".l10n()}
var lsMenuDictionaries:String{return "menu.dictionaries".l10n()}
var lsMenuHelp:String{return "menu.help".l10n()}



// приоритеты

var lsPriority:String{return "priority".l10n()}
var lsNewPriority:String{return "newPriority".l10n()}
var lsPrioritiesNotFound:String{return "prioritiesNotFound".l10n()}
var lsSelectPriority:String{return "selectPriority".l10n()}
var lsPriorities:String{return "priorities".l10n()}
var lsNoPriority:String { return "noPriority".l10n()}
var lsCanDrag:String{return "canDrag".l10n()}



// задачи

var lsNewTask:String{return "newTask".l10n()}
var lsTasksNotFound:String{return "tasksNotFound".l10n()}
var lsQuickTask:String{return "quickTask".l10n()}
var lsCompleteTask:String{return "completeTask".l10n()}
var lsTaskList:String{return "taskList".l10n()}
var lsConfirmDeleteTask:String{return "confirmDeleteTask".l10n()}
var lsConfirmCompleteTask:String{return "confirmCompleteTask".l10n()}


// фильтрация

var lsSelectedTasksWillShow:String{return "selectedTasksWillShow".l10n()}
var lsCanFilter:String{return "canFilter".l10n()}
var lsTasksWithEmptyCategory:String{return "tasksWithEmptyCategory".l10n()}
var lsTasksWithEmptyPriority:String{return "tasksWithEmptyPriority".l10n()}
var lsTasksWithoutDate:String{return "tasksWithoutDate".l10n()}
var lsFilter:String{return "menu.filters".l10n()}


// сообщение, если новая/обновленная задача не будет отображаться в текущем списке

var lsNotShowEmptyCategories:String{return "notShowEmptyCategories".l10n()}
var lsNotShowEmptyPriorities:String{return "notShowEmptyPriorities".l10n()}
var lsNotShowWithoutDate:String{return "notShowWithoutDate".l10n()}
var lsNotShowCategory:String{return "notShowCategory".l10n()}
var lsNotShowPriority:String{return "notShowPriority".l10n()}
var lsNameNotContains:String{return "nameNotContains".l10n()}
var lsTaskAddedButNotShow:String{return "taskAddedButNotShow".l10n()}
var lsTaskUpdatedButNotShow:String{return "taskUpdatedButNotShow".l10n()}


// язык

var lsLang:String{return "lang".l10n()}
var lsLangChanged:String{return "langChanged".l10n()}
var lsSelectLang:String{return "selectLang".l10n()}


// демо данные (при первом запуске приложения)

// приоритеты
var lsLowPriority:String{return "demoPriorityLow".l10n()}
var lsNormalPriority:String{return "demoPriorityNormal".l10n()}
var lsHighPriority:String{return "demoPriorityHigh".l10n()}


// категории
var lsDemoCat1:String{return "demoCat1".l10n()}
var lsDemoCat2:String{return "demoCat2".l10n()}
var lsDemoCat3:String{return "demoCat3".l10n()}
var lsDemoCat4:String{return "demoCat4".l10n()}
var lsDemoCat5:String{return "demoCat5".l10n()}

// задания
var lsDemoTask1:String{return "demoTask1".l10n()}
var lsDemoTask2:String{return "demoTask2".l10n()}
var lsDemoTask3:String{return "demoTask3".l10n()}
var lsDemoTask4:String{return "demoTask4".l10n()}
var lsDemoTask5:String{return "demoTask5".l10n()}
var lsDemoTask6:String{return "demoTask6".l10n()}
var lsDemoTask7:String{return "demoTask7".l10n()}
var lsDemoTask8:String{return "demoTask8".l10n()}
var lsDemoTask9:String{return "demoTask9".l10n()}
var lsDemoTask10:String{return "demoTask10".l10n()}

// доп. инфо
var lsDemoInfo1:String{return "demoInfo1".l10n()}
var lsDemoInfo4:String{return "demoInfo4".l10n()}
var lsDemoInfo5:String{return "demoInfo5".l10n()}
var lsDemoInfo6:String{return "demoInfo6".l10n()}
var lsDemoInfo9:String{return "demoInfo9".l10n()}



// intro
var lsNext:String{return "next".l10n()}
var lsSkip:String{return "skip".l10n()}
var lsBegin:String{return "begin".l10n()}


var lsIntroTaskList:String{return "introTaskList".l10n()}
var lsIntroFilter:String{return "introFilter".l10n()}
var lsIntroSearch:String{return "introSearch".l10n()}
var lsIntroDict:String{return "introDict".l10n()}
var lsIntroColors:String{return "introColors".l10n()}


