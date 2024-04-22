class_name __GDRx_Init__
## Provides access to GDRx-library types.
##
## Bridge between GDRx-library type implementations and [__GDRx_Singleton__]

# =========================================================================== #
#   Notification
# =========================================================================== #
var NotificationOnNext_ = load("res://addons/reactivex/notification/onnext.gd")
var NotificationOnError_ = load("res://addons/reactivex/notification/onerror.gd")
var NotificationOnCompleted_ = load("res://addons/reactivex/notification/oncompleted.gd")

# =========================================================================== #
#   Internals
# =========================================================================== #
var Heap_ = load("res://addons/reactivex/internal/heap.gd")
var Basic_ = load("res://addons/reactivex/internal/basic.gd")
var Concurrency_ = load("res://addons/reactivex/internal/concurrency.gd")
var Util_ = load("res://addons/reactivex/internal/utils.gd")

# =========================================================================== #
#   Pipe
# =========================================================================== #
var Pipe_ = load("res://addons/reactivex/pipe.gd")
