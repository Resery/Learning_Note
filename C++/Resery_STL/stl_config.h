#pragma once

#define __STL_NAME Resery_STL

#define __STL_BEGIN_NAMESPACE namespace Resery_STL {
#define __STL_END_NAMESPACE }

#define __STL_TRY try
#define __STL_UNWIND(action) catch(...){action; throw;}

#define __STL_TEMPLATE_NULL template<>