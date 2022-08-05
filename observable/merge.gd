static func merge_(sources : Array[Observable]) -> Observable:
	return GDRx.obs.from_iterable(GDRx.util.Iter(sources)).pipe1(GDRx.op.merge_all())
