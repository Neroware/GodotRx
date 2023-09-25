class_name __GDRx_Init__
## Provides access to GDRx-library types.
##
## Bridge between GDRx-library type implementations and [__GDRx_Singleton__]

# =========================================================================== #
#   Notification
# =========================================================================== #
var NotificationOnNext_ # = load("res://reactivex/notification/onnext.gd")
var NotificationOnError_ # = load("res://reactivex/notification/onerror.gd")
var NotificationOnCompleted_ # = load("res://reactivex/notification/oncompleted.gd")

# =========================================================================== #
#   Internals
# =========================================================================== #
var Heap_ = load("res://reactivex/internal/heap.gd")
var Basic_ = load("res://reactivex/internal/basic.gd")
var Concurrency_ = load("res://reactivex/internal/concurrency.gd")
var Util_ = load("res://reactivex/internal/utils.gd")

# =========================================================================== #
#   Exception
# =========================================================================== #
var Exception_ # = load("res://reactivex/exception/exception.gd")

# =========================================================================== #
#   Pipe
# =========================================================================== #
var Pipe_ # = load("res://reactivex/pipe.gd")
